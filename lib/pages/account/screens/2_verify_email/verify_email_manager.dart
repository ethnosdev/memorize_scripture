import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';

class VerifyEmailManager {
  VerifyEmailManager({
    required this.screenNotifier,
    required this.email,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final String email;

  void verifyEmailDone() {
    screenNotifier.value = AccountScreenType.signIn;
  }

  Future<void> resendVerificationEmail() async {
    await getIt<AuthService>().resendVerificationEmail(email);
  }
}
