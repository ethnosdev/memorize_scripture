import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';
import 'package:memorize_scripture/pages/account/shared/validation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';
import 'package:memorize_scripture/services/auth/exceptions.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpManager {
  SignUpManager({
    required this.screenNotifier,
    required this.onSignedUp,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final void Function(String) onSignedUp;

  final emailNotifier = ValueNotifier<String?>(null);
  final passwordNotifier = ValueNotifier(
    const TextFieldData(isObscured: false),
  );
  final waitingNotifier = ValueNotifier<bool>(false);

  Future<void> createAccount({
    required String email,
    required String passphrase,
  }) async {
    if (!_emailAndPasswordOk(email, passphrase)) return;
    waitingNotifier.value = true;
    try {
      await getIt<AuthService>().createAccount(
        email: email,
        passphrase: passphrase,
      );
      onSignedUp.call('Account created successfully.\n\n'
          'Check your email and verify your account before signing in.');
      screenNotifier.value = AccountScreenType.signIn;
    } on EmailException catch (e) {
      emailNotifier.value = e.message;
    } on PasswordException catch (e) {
      passwordNotifier.value = TextFieldData(errorText: e.message);
    } finally {
      waitingNotifier.value = false;
    }
  }

  bool _emailAndPasswordOk(String email, String passphrase) {
    var error = validateEmail(email);
    if (error != null) {
      emailNotifier.value = error;
      return false;
    }
    error = validatePassphrase(passphrase);
    if (error != null) {
      passwordNotifier.value = TextFieldData(errorText: error);
      return false;
    }
    return true;
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

  Future<void> showPrivacyPolicy() async {
    await _launch(AppStrings.privacyPolicyUrl);
  }

  Future<void> showTermsOfService() async {
    await _launch(AppStrings.tosUrl);
  }

  Future<void> _launch(String webpage) async {
    final url = Uri.parse(webpage);
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void showSignInScreen() {
    screenNotifier.value = AccountScreenType.signIn;
    passwordNotifier.value = const TextFieldData(isObscured: true);
  }
}
