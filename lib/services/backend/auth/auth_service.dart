import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthService {
  AuthService(PocketBase pb) : _pb = pb;
  final PocketBase _pb;

  bool get isLoggedIn => _pb.authStore.isValid;

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
      final record = await _pb.collection('users').create(body: body);
      print(record);
      await _pb.collection('users').requestVerification(email);
    } on ClientException catch (e) {
      print(e);
      if (e.statusCode == 0) {
        throw ConnectionRefusedException();
      }
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

  Future<User> signIn({
    required String email,
    required String passphrase,
  }) async {
    RecordAuth authData;
    try {
      authData = await _pb.collection('users').authWithPassword(
            email,
            passphrase,
          );
      print(authData);
      final isVerified = authData.record?.getBoolValue('verified') ?? false;
      if (!isVerified) {
        throw UserNotVerifiedException('User not verified');
      }
      return User(
        id: authData.record!.id,
        email: email,
        token: authData.token,
      );
    } on ClientException catch (e) {
      final code = e.statusCode;
      switch (code) {
        case 0:
          throw ConnectionRefusedException();
        case 400:
          throw FailedToAuthenticateException(
              'Email or password was incorrect');
        default:
          throw Exception(e);
      }
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  User? getUser() {
    if (_pb.authStore.model == null) return null;
    print(_pb.authStore.model);
    final model = _pb.authStore.model as RecordModel;
    return User(
      id: model.id,
      email: model.getStringValue('email'),
      token: model.getStringValue('token'),
    );
  }

  Future<void> signOut() async {
    _pb.authStore.clear();
  }

  Future<void> deleteAccount() async {
    try {
      final model = _pb.authStore.model as RecordModel;
      await _pb.collection('users').delete(model.id);
      _pb.authStore.clear();
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw ConnectionRefusedException();
      }
      throw Exception(e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _pb.collection('users').requestPasswordReset(email);
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw ConnectionRefusedException();
      }
      throw Exception(e);
    }
  }
}