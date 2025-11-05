import 'package:memorize_scripture/common/dialog/result_from_restoring_backup.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:pocketbase/pocketbase.dart';

class WebApi {
  WebApi(PocketBase pb) : _pb = pb;
  final PocketBase _pb;

  Future<void> syncVerses({
    required User? user,
    required void Function(String) onFinished,
  }) async {
    if (user == null) throw UserNotLoggedInException();

    final lastLocalUpdate = getIt<UserSettings>().lastLocalUpdate;
    final serverIdDate = await _getLastServerUpdateDate(user);
    final serverHasChanges = serverIdDate != null;
    final localHasChanges = lastLocalUpdate != null;

    try {
      if (serverHasChanges) {
        if (localHasChanges) {
          final (id, lastServerUpdate) = serverIdDate;
          if (lastLocalUpdate.isBefore(lastServerUpdate)) {
            await _pullChangesFromServer(user, onFinished);
          } else if (lastLocalUpdate.isAfter(lastServerUpdate)) {
            await _pushUpdateToServer(user, id);
            onFinished
                .call("Your changes were successfully saved on the server.");
          } else {
            onFinished.call('There are no changes to update.');
          }
        } else {
          // server has changes but local has no changes
          await _pullChangesFromServer(user, onFinished);
        }
      } else {
        if (localHasChanges) {
          // Server has no record but there are local changes.
          await _pushNewRecordToServer(user);
          onFinished
              .call('Your changes were successfully saved on the server.');
        } else {
          // No changes anywhere. Do nothing.
          onFinished.call('There are no changes to update.');
        }
      }
    } catch (e) {
      onFinished.call('There was a problem connecting to the server: $e');
    }
  }

  // returns id and DateTime of last record update on server
  Future<(String, DateTime)?> _getLastServerUpdateDate(User user) async {
    final result = await _pb
        .collection('backup') //
        .getList(
          perPage: 1,
          fields: 'id,updated',
        );
    if (result.items.isEmpty) return null;
    final record = result.items.first;
    return (record.id, DateTime.parse(record.get<String>('updated')));
  }

  Future<void> _pushNewRecordToServer(User user) async {
    final dbBackup = await getIt<LocalStorage>().backupCollections();
    final record = await _pb.collection('backup').create(
      body: {
        "user": user.id,
        "data": dbBackup,
      },
      fields: 'id,updated',
    );
    final updated = record.get<String>('updated');
    await getIt<UserSettings>().setLastLocalUpdate(updated);
  }

  Future<void> _pushUpdateToServer(User user, String id) async {
    final dbBackup = await getIt<LocalStorage>().backupCollections();
    final record = await _pb.collection('backup').update(
          id,
          body: {
            "user": user.id,
            "data": dbBackup,
          },
          fields: 'id,updated',
        );
    final updated = record.get<String>('updated');
    await getIt<UserSettings>().setLastLocalUpdate(updated);
  }

  Future<void> _pullChangesFromServer(
    User user,
    void Function(String message) onFinished,
  ) async {
    // get the verses from the server
    final result = await _pb
        .collection('backup') //
        .getList(perPage: 1);
    if (result.items.isEmpty) return;
    final record = result.items.first;
    final data = record.data['data'];

    // restore the verses locally
    try {
      final (added, updated, errorCount) =
          await getIt<LocalStorage>().restoreBackup(
        data,
        timestamp: record.get<String>('updated'),
      );
      final message = resultOfRestoringBackup(added, updated, errorCount);
      onFinished.call(message);
    } on FormatException {
      onFinished.call('There was an error getting your verses from the server');
    }
  }
}
