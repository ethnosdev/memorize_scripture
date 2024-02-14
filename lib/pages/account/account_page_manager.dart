import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';

import 'shared/account_screen_type.dart';

// enum LoginStatus {
//   initial,
//   loading,
//   notLoggedIn,
//   loggedIn,
// }

class AccountPageManager {
  final screenNotifier = ValueNotifier(AccountScreenType.signUp);

  Future<void> init() async {
    screenNotifier.value = AccountScreenType.initial;
    // await Future.delayed(Duration(seconds: 2));
    final loggedIn = getIt<AuthService>().isLoggedIn;
    // await getIt<AuthService>().init();
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
