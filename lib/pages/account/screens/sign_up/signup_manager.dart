import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';
import 'package:memorize_scripture/pages/account/shared/validation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/backend/exceptions.dart';
import 'package:memorize_scripture/services/backend/backend_service.dart';
import 'package:memorize_scripture/services/secure_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpManager {
  SignUpManager({
    required this.screenNotifier,
    required this.onResult,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final void Function(String, String) onResult;

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
      await getIt<BackendService>().auth.createAccount(
            email: email,
            passphrase: passphrase,
          );
      await getIt<SecureStorage>().setEmail(email);
      onResult.call('Account created',
          'Check your email and verify your account before signing in.');
      screenNotifier.value = SignIn(email: email);
    } on EmailException catch (e) {
      emailNotifier.value = e.message;
    } on PasswordException catch (e) {
      passwordNotifier.value = TextFieldData(errorText: e.message);
    } on ConnectionRefusedException catch (e) {
      onResult.call('Error', e.message);
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

  void showSignInScreen(String email) {
    screenNotifier.value = SignIn(email: email);
    passwordNotifier.value = const TextFieldData(isObscured: true);
  }
}
