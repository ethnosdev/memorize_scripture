import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/backend_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';

import 'shared/account_screen_type.dart';

class AccountPageManager {
  final screenNotifier = ValueNotifier<AccountScreenType>(Initial());

  Future<void> init() async {
    screenNotifier.value = Initial();

    await getIt<BackendService>().init();

    final user = getIt<BackendService>().auth.getUser();
    if (user != null) {
      screenNotifier.value = LoggedIn(user: user);
      return;
    }

    final storedEmail = await getIt<SecureStorage>().getEmail();
    if (storedEmail == null) {
      screenNotifier.value = SignUp();
    } else {
      screenNotifier.value = SignIn(email: storedEmail);
    }
  }
}
