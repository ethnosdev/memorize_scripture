import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:pocketbase/pocketbase.dart';

class WebApi {
  WebApi(PocketBase pb) : _pb = pb;
  final PocketBase _pb;

  Future<void> syncVerses(User? user) async {
    if (user == null) throw UserNotLoggedInException();

    final lastLocalUpdate = getIt<UserSettings>().lastLocalUpdate;
    final idDate = await _getLastServerUpdate(user);

    // no changes anywhere
    if (idDate == null && lastLocalUpdate == null) {
      return;
    }

    // server null but local has changes
    if (idDate == null) {
      await _createNewServerRecord(user);
      return;
    }

    final (id, lastServerUpdate) = idDate;

    // local same as server
    if (lastServerUpdate == lastLocalUpdate) {
      return;
    }

    // server has newer update
    if (lastLocalUpdate!.isBefore(lastServerUpdate)) {
      await _getUpdateFromServer(user);
      return;
    }

    // local has newer update
    await _updateServerRecord(user, id);
  }

  Future<(String, DateTime)?> _getLastServerUpdate(User user) async {
    try {
      final record = await _pb
          .collection('backup') //
          .getFirstListItem(
            'user="${user.id}"',
            fields: 'id,updated',
          );
      return (record.id, DateTime.parse(record.updated));
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        // There was no record for this user.
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<void> _createNewServerRecord(User user) async {
    final dbBackup = await _prepareLocalBackup();
    final record = await _pb.collection('backup').create(
      body: {
        "user": user.id,
        "data": dbBackup,
      },
      fields: 'id,updated',
    );
    final updated = record.updated;
    await getIt<UserSettings>().setLastLocalUpdate(updated);
  }

  Future<void> _updateServerRecord(User user, String id) async {
    final dbBackup = await _prepareLocalBackup();
    final record = await _pb.collection('backup').update(
          id,
          body: {
            "user": user.id,
            "data": dbBackup,
          },
          fields: 'id,updated',
        );
    final updated = record.updated;
    await getIt<UserSettings>().setLastLocalUpdate(updated);
  }

  Future<void> _getUpdateFromServer(User user) async {
    // TODO
    // Get all the server changes
    // Store them locally
    // if successful then update the last sync date
  }

  Future<String> _prepareLocalBackup() async {
    // Get all the local changes
    return await getIt<LocalStorage>().backupCollections();
  }
}
