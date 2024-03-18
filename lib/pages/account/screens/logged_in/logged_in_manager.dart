import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/auth/user.dart';
import 'package:memorize_scripture/services/backend/backend_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';

class LoggedInManager {
  LoggedInManager({required this.screenNotifier});
  final ValueNotifier<AccountScreenType> screenNotifier;
  final waitingNotifier = ValueNotifier<bool>(false);

  //void Function(String message)? onError;

  Future<void> signOut(User user) async {
    await getIt<BackendService>().auth.signOut();
    screenNotifier.value = SignIn(email: user.email);
  }

  Future<void> deleteAccount(void Function(String) onError) async {
    try {
      await getIt<BackendService>().auth.deleteAccount();
      screenNotifier.value = SignUp();
      await getIt<SecureStorage>().deleteEmail();
    } on ConnectionRefusedException catch (e) {
      onError.call(e.message);
    } on ServerErrorException catch (e) {
      onError.call(e.message);
    }
  }

  Future<void> syncVerses(void Function(String) onResult) async {
    final user = getIt<BackendService>().auth.getUser();
    waitingNotifier.value = true;
    try {
      await getIt<BackendService>().webApi.syncVerses(
            user: user,
            onFinished: onResult,
          );
      await getIt<HomePageManager>().init();
    } on UserNotLoggedInException {
      screenNotifier.value = SignIn(email: '');
    } on ConnectionRefusedException catch (e) {
      onResult.call(e.message);
    } on ServerErrorException catch (e) {
      onResult.call(e.message);
    } catch (e) {
      onResult.call(e.toString());
    } finally {
      waitingNotifier.value = false;
    }
  }
}
