import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';

import 'shared/account_screen_type.dart';

enum LoginStatus {
  initial,
  loading,
  notLoggedIn,
  loggedIn,
}

class AccountPageManager {
  final screenNotifier = ValueNotifier(AccountScreenType.signUp);
  final statusNotifier = ValueNotifier(LoginStatus.initial);

  String? get currentEmail => null;

  Future<void> init() async {
    statusNotifier.value = LoginStatus.initial;
    // await Future.delayed(Duration(seconds: 2));
    await getIt<AuthService>().init();
    statusNotifier.value = LoginStatus.notLoggedIn;
  }
}
