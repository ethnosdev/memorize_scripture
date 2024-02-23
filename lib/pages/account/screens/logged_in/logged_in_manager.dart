import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:memorize_scripture/services/backend/backend_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';

class LoggedInManager {
  LoggedInManager({required this.screenNotifier});
  final ValueNotifier<AccountScreenType> screenNotifier;
  final waitingNotifier = ValueNotifier<bool>(false);

  void Function(String title, String message)? onResult;

  Future<void> signOut(User user) async {
    await getIt<BackendService>().auth.signOut();
    screenNotifier.value = SignIn(email: user.email);
  }

  Future<void> deleteAccount() async {
    try {
      await getIt<BackendService>().auth.deleteAccount();
      screenNotifier.value = SignUp();
      await getIt<SecureStorage>().deleteEmail();
      // TODO: mark all verses as unsynced
    } on ConnectionRefusedException catch (e) {
      onResult?.call('Error', e.message);
    }
  }

  Future<void> syncVerses(void Function(String) onFinished) async {
    final user = getIt<BackendService>().auth.getUser();
    waitingNotifier.value = true;
    try {
      await getIt<BackendService>().webApi.syncVerses(
            user: user,
            onFinished: onFinished,
          );
    } on UserNotLoggedInException {
      screenNotifier.value = SignIn(email: '');
    } on ConnectionRefusedException catch (e) {
      onResult?.call('Error', e.message);
    } finally {
      waitingNotifier.value = false;
    }
  }
}
