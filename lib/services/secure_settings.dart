import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<String?> getEmail();
  Future<void> setEmail(String email);
  Future<void> deleteEmail();

  Future<String?> getToken();
  Future<void> setToken(String token);
  Future<void> deleteToken();
}

class LocalSecureStorage implements SecureStorage {
  static const _emailKey = 'email';
  static const _tokenKey = 'token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    mOptions: MacOsOptions(),
  );

  @override
  Future<String?> getEmail() async {
    final email = await _storage.read(key: _emailKey);
    return email;
  }

  @override
  Future<void> setEmail(String email) async {
    await _storage.delete(key: _emailKey);
    await _storage.write(key: _emailKey, value: email);
  }

  @override
  Future<void> deleteEmail() async {
    await _storage.delete(key: _emailKey);
  }

  @override
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token;
  }

  @override
  Future<void> setToken(String token) async {
    await _storage.delete(key: _tokenKey);
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
