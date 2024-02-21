import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/exceptions.dart';
import 'package:memorize_scripture/services/auth/user.dart';
import 'package:memorize_scripture/services/local_storage/data_repository.dart';

class WebApi {
  final _baseUrl = (Platform.isAndroid) //
      ? 'http://10.0.2.2:8080/'
      : 'http://127.0.0.1:8080/';

  Future<void> syncVerses(User? user) async {
    if (user == null) throw UserNotLoggedInException();

    // get unsynced local changes
    final changes = await getIt<LocalStorage>().fetchUnsyncedChanges();
    final jsonChanges = await compute(jsonEncode, changes);
    print(jsonChanges);

    // send them to the server
    // final url = Uri.parse('$_baseUrl/sync');
    // final headers = {
    //   'Authorization': 'Bearer ${user.token}',
    //   'Content-Type': 'application/json'
    // };
    // final result = await http.put(url, headers: headers, body: jsonChanges);

    // // update local database with server response
    // final updates = jsonDecode(result.body);
    // await getIt<LocalStorage>().updateFromRemoteSync(updates);
  }
}
