import 'package:memorize_scripture/services/backend/auth/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:pocketbase/pocketbase.dart';

class WebApi {
  WebApi(PocketBase pb) : _pb = pb;
  final PocketBase _pb;

  Future<void> syncVerses(User? user) async {
    if (user == null) throw UserNotLoggedInException();

    // check last update from server
    // check last update from local storage
    // if local newer then push local changes to server
    // else pull server changes to local storage
  }
}
