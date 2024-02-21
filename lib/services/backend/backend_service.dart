import 'dart:io';

import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/auth/auth_service.dart';
import 'package:memorize_scripture/services/backend/web_api/web_api.dart';
import 'package:memorize_scripture/services/secure_settings.dart';
import 'package:pocketbase/pocketbase.dart';

/// This class separates auth and web api.
abstract class BackendService {
  Future<void> init();

  AuthService get auth;
  WebApi get webApi;
}

class PocketBaseBackend implements BackendService {
  late final PocketBase _pb;
  final _baseUrl = (Platform.isAndroid) //
      ? 'http://10.0.2.2:8090/'
      : 'http://127.0.0.1:8090/';

  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    final storage = getIt<SecureStorage>();
    final store = AsyncAuthStore(
      initial: await storage.getToken(),
      save: (String data) => storage.setToken(data),
      clear: storage.deleteToken,
    );
    _pb = PocketBase(_baseUrl, authStore: store);

    _authService = AuthService(_pb);
    _webApi = WebApi(_pb);

    _isInitialized = true;
  }

  @override
  AuthService get auth => _authService;
  late AuthService _authService;

  @override
  WebApi get webApi => _webApi;
  late WebApi _webApi;
}
