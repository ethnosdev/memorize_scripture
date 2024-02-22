import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:pocketbase/pocketbase.dart';

class WebApi {
  WebApi(PocketBase pb) : _pb = pb;
  final PocketBase _pb;

  Future<void> syncVerses(User? user) async {
    if (user == null) throw UserNotLoggedInException();

    // check last update from server
    final lastServerUpdate = await _getLastServerUpdate(user);
    if (lastServerUpdate == null) {
      _pushLocalChangesToServer(user: user, create: true);
      return;
    }

    // check last update from settings
    final lastLocalUpdate = getIt<UserSettings>().lastSync;
    if (lastLocalUpdate == null) {
      _pullLocalChangesFromServer(user);
      return;
    }

    // no need to do anything if both are the same
    if (lastLocalUpdate == lastServerUpdate) {
      return;
    }

    // if local newer then push local changes to server
    if (lastLocalUpdate.isAfter(lastServerUpdate)) {
      _pushLocalChangesToServer(user: user, create: false);
      return;
    }

    // else pull server changes to local storage
    _pullLocalChangesFromServer(user);
  }

  Future<DateTime?> _getLastServerUpdate(User user) async {
    try {
      final record = await _pb
          .collection('backup') //
          .getFirstListItem(
            'user="${user.id}"',
            fields: 'updated',
          );
      return DateTime.parse(record.updated);
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        // There was no record for this user.
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<void> _pushLocalChangesToServer({
    required User user,
    required bool create,
  }) async {
    // Get all the local changes
    // Push them to the server
    if (create) {
      // Create a new record
      print('_pushLocalChangesToServer: create');
    } else {
      // Update the existing record
      print('_pushLocalChangesToServer: update');
    }
    // if successful then update the last sync date
  }

  Future<void> _pullLocalChangesFromServer(User user) async {
    print('_pullLocalChangesFromServer');
    // Get all the server changes
    // Store them locally
    // if successful then update the last sync date
  }
}
