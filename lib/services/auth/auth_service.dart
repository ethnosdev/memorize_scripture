import 'package:memorize_scripture/services/auth/exceptions.dart';
import 'package:memorize_scripture/services/auth/user.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final pb = PocketBase('http://127.0.0.1:8090/');

  bool get isLoggedIn => pb.authStore.isValid;

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
      await pb.collection('users').requestVerification(email);
    } on ClientException catch (e) {
      final data = e.response['data'];
      if (data['email'] != null) {
        final message = data['email']['message'];
        throw EmailException(message);
      } else if (data['password'] != null) {
        final message = data['password']['message'];
        throw PasswordException(message);
      }
      throw Exception(e);
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

  Future<User> getUser() async {
    print(pb.authStore.model);
    final model = pb.authStore.model as RecordModel;
    return User(email: model.getStringValue('email'));
  }

  Future<void> signOut() async {
    pb.authStore.clear();
  }

  Future<void> deleteAccount() async {
    final model = pb.authStore.model as RecordModel;
    await pb.collection('users').delete(model.id);
    pb.authStore.clear();
  }
}
