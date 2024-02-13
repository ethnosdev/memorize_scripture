import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<String?> getEmail();
  Future<void> setEmail(String email);
}

class LocalSecureStorage implements SecureStorage {
  static const _emailKey = 'email';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  @override
  Future<String?> getEmail() async {
    final email = await _storage.read(key: _emailKey);
    print('reading email: $email');
    return email;
  }

  @override
  Future<void> setEmail(String email) async {
    print('writing email: $email');
    await _storage.write(key: _emailKey, value: email);
    final read = await _storage.read(key: _emailKey);
    print('reading email: $read');
  }
}
