import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/backend_service.dart';

class NewPasswordManager {
  NewPasswordManager({
    required this.screenNotifier,
    required this.onSuccess,
    required this.onError,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final void Function(String, String) onSuccess;
  final void Function(String) onError;
  final waitingNotifier = ValueNotifier<bool>(false);

  Future<void> resetPassword({
    required String email,
  }) async {
    waitingNotifier.value = true;
    try {
      await getIt<BackendService>().auth.resetPassword(
            email: email,
          );
      onSuccess.call(
          'Reset sent',
          'You need to check your email and click the Verify button '
              'before the change will take effect.');
      screenNotifier.value = SignIn(email: email);
    } on ConnectionRefusedException catch (e) {
      onError.call(e.message);
    } on ServerErrorException catch (e) {
      onError.call(e.message);
    } finally {
      waitingNotifier.value = false;
    }
  }
}
