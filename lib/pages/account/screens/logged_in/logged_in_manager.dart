import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';
import 'package:memorize_scripture/services/auth/exceptions.dart';
import 'package:memorize_scripture/services/auth/user.dart';
import 'package:memorize_scripture/services/secure_settings.dart';
import 'package:memorize_scripture/services/web_api/web_api.dart';

class LoggedInManager {
  LoggedInManager({required this.screenNotifier});
  final ValueNotifier<AccountScreenType> screenNotifier;
  final waitingNotifier = ValueNotifier<bool>(false);

  void Function(String title, String message)? onResult;

  Future<void> signOut(User user) async {
    await getIt<AuthService>().signOut();
    screenNotifier.value = SignIn(email: user.email);
  }

  Future<void> deleteAccount() async {
    try {
      await getIt<AuthService>().deleteAccount();
      screenNotifier.value = SignUp();
      await getIt<SecureStorage>().deleteEmail();
      // TODO: mark all verses as unsynced
    } on ConnectionRefusedException catch (e) {
      onResult?.call('Error', e.message);
    }
  }

  Future<void> syncVerses() async {
    final user = getIt<AuthService>().getUser();
    waitingNotifier.value = true;
    try {
      await getIt<WebApi>().syncVerses(user);
    } on UserNotLoggedInException {
      screenNotifier.value = SignIn(email: '');
    } on ConnectionRefusedException catch (e) {
      onResult?.call('Error', e.message);
    } finally {
      waitingNotifier.value = false;
    }
  }
}
