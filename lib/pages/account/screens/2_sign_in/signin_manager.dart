import 'package:flutter/widgets.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';
import 'package:memorize_scripture/services/auth/exceptions.dart';
import 'package:memorize_scripture/services/secure_settings.dart';

import '../../shared/validation.dart';

class SignInManager {
  SignInManager({
    required this.screenNotifier,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;

  void Function(String)? onUserNotVerified;
  void Function(String)? onResult;

  final emailNotifier = ValueNotifier<String?>(null);
  final passwordNotifier = ValueNotifier(
    const TextFieldData(isObscured: true),
  );
  final waitingNotifier = ValueNotifier<bool>(false);

  void showSignUpScreen() {
    screenNotifier.value = SignUp();
  }

  void onEmailChanged(String value) {
    if (emailNotifier.value != null) {
      emailNotifier.value = null;
    }
  }

  void onPasswordChanged(String value) {
    if (passwordNotifier.value.hasError) {
      passwordNotifier.value = TextFieldData(
        errorText: null,
        isObscured: passwordNotifier.value.isObscured,
      );
    }
  }

  void togglePasswordVisibility() {
    final data = passwordNotifier.value;
    passwordNotifier.value = TextFieldData(
      errorText: data.errorText,
      isObscured: !data.isObscured,
    );
  }

  void signIn({required String email, required String passphrase}) async {
    if (!_emailAndPasswordOk(email, passphrase)) return;
    waitingNotifier.value = true;
    await getIt<SecureStorage>().setEmail(email);
    try {
      final user = await getIt<AuthService>().signIn(
        email: email,
        passphrase: passphrase,
      );
      screenNotifier.value = LoggedIn(user: user);
    } on UserNotVerifiedException {
      onUserNotVerified?.call(email);
    } on FailedToAuthenticateException catch (e) {
      passwordNotifier.value = TextFieldData(
        errorText: e.message,
        isObscured: passwordNotifier.value.isObscured,
      );
    } on ConnectionRefusedException catch (e) {
      onResult?.call(e.message);
    } finally {
      waitingNotifier.value = false;
    }
  }

  bool _emailAndPasswordOk(String email, String passphrase) {
    final error = validateEmail(email);
    if (error != null) {
      emailNotifier.value = error;
      return false;
    }
    if (passphrase.isEmpty) {
      passwordNotifier.value = TextFieldData(
        errorText: 'Passphrase cannot be empty',
        isObscured: passwordNotifier.value.isObscured,
      );
      return false;
    }
    return true;
  }

  void forgotPassword(String email) {
    final error = validateEmail(email);
    if (error != null) {
      emailNotifier.value = error;
      return;
    }
    screenNotifier.value = NewPassword(email: email);
  }

  Future<void> resendEmailVerification(String email) async {
    await getIt<AuthService>().resendVerificationEmail(email);
    onResult?.call('Verification email was sent.');
  }
}
