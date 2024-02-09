import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final pb = PocketBase('http://127.0.0.1:8090/');

  Future<void> init() async {}

  Future<void> createAccount({
    required String email,
    required String passphrase,
  }) async {
    final body = <String, dynamic>{
      "email": email,
      "password": passphrase,
      "passwordConfirm": passphrase,
    };

    final record = await pb.collection('users').create(body: body);
    print(record);
  }
}
