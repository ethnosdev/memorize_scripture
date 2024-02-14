import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';

import 'shared/account_screen_type.dart';

class AccountPageManager {
  final screenNotifier = ValueNotifier(AccountScreenType.signUp);

  Future<void> init() async {
    screenNotifier.value = AccountScreenType.initial;
    await getIt<AuthService>().init();

    final loggedIn = getIt<AuthService>().isLoggedIn;
    if (loggedIn) {
      screenNotifier.value = AccountScreenType.loggedIn;
      return;
    }

    final storedEmail = await getIt<SecureStorage>().getEmail();
    if (storedEmail == null) {
      screenNotifier.value = AccountScreenType.signUp;
    } else {
      screenNotifier.value = AccountScreenType.signIn;
    }
  }
}
