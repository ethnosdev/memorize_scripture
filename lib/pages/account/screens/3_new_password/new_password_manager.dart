import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';

class NewPasswordManager {
  NewPasswordManager({
    required this.screenNotifier,
    required this.onResetSent,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final void Function(String, String) onResetSent;
  final waitingNotifier = ValueNotifier<bool>(false);

  Future<void> resetPassword({
    required String email,
  }) async {
    waitingNotifier.value = true;
    try {
      await getIt<AuthService>().resetPassword(
        email: email,
      );
      onResetSent.call(
          'Reset sent',
          'You need to check your email and click the Verify button '
              'before the change will take effect.');
      screenNotifier.value = SignIn(email: email);
    } finally {
      waitingNotifier.value = false;
    }
  }
}
