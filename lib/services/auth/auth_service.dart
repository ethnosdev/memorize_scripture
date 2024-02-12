import 'package:memorize_scripture/services/auth/exceptions.dart';
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

    try {
      final record = await pb.collection('users').create(body: body);
      print(record);
    } on ClientException catch (e) {
      final data = e.response['data'];
      if (data['email'] != null) {
        final message = data['email']['message'];
        throw EmailException(message);
      } else if (data['password'] != null) {
        final message = data['password']['message'];
        throw PasswordException(message);
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String passphrase,
  }) async {
    final authData =
        await pb.collection('users').authWithPassword(email, passphrase);
    print(authData);
    final isVerified = authData.record?.getBoolValue('verified') ?? false;
    if (!isVerified) {
      throw UserNotVerifiedException('User not verified');
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    await pb.collection('users').requestVerification(email);
  }
}
