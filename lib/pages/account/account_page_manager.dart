import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/remote_storage/remote_storage.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TextFieldData {
  const TextFieldData({
    this.errorText,
    this.isObscured = false,
  });

  final String? errorText;
  final bool isObscured;
  bool get hasError => errorText != null;
}

enum AccountScreenType {
  signUp,
  signIn,
  forgotPasswordEmail,
  forgotPasswordVerify,
  forgotPasswordNewPassword,
}

enum LoginStatus {
  initial,
  loading,
  notLoggedIn,
  loggedIn,
}

class AccountPageManager {
  final titleNotifier = ValueNotifier('');
  final screenNotifier =
      ValueNotifier<AccountScreenType>(AccountScreenType.signUp);
  final emailNotifier = ValueNotifier(const TextFieldData());
  final passwordNotifier =
      ValueNotifier(const TextFieldData(isObscured: false));
  final resetCodeNotifier = ValueNotifier(const TextFieldData());
  final statusNotifier = ValueNotifier(LoginStatus.initial);

  void Function(String)? onError;

  Future<void> init() async {
    statusNotifier.value = LoginStatus.initial;
    // await Future.delayed(Duration(seconds: 2));
    await getIt<RemoteStorage>().init();
    statusNotifier.value = LoginStatus.notLoggedIn;
  }

  void togglePasswordVisibility() {
    final data = passwordNotifier.value;
    passwordNotifier.value = TextFieldData(
      errorText: data.errorText,
      isObscured: !data.isObscured,
    );
  }

  Future<void> createAccount({
    required String email,
    required String passphrase,
  }) async {
    if (!_emailAndPasswordOk(email, passphrase)) return;
    await getIt<RemoteStorage>().createAccount(
      email: email,
      passphrase: passphrase,
    );
  }

  void login({required String email, required String passphrase}) {
    if (!_emailAndPasswordOk(email, passphrase)) return;
  }

  bool _emailAndPasswordOk(String email, String passphrase) {
    return _validateEmail(email) && _validatePassphrase(passphrase);
  }

  /// returns true is email is valid
  bool _validateEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    String? error;
    if (email.isEmpty) {
      error = 'Email cannot be empty';
    } else if (!emailRegex.hasMatch(email)) {
      error = 'Invalid email address';
    }

    if (error == null) return true;

    emailNotifier.value = TextFieldData(
      errorText: error,
      isObscured: emailNotifier.value.isObscured,
    );

    return false;
  }

  bool _validatePassphrase(String passphrase) {
    final words = passphrase.split(' ');
    var count = 0;
    for (final word in words) {
      if (word.isNotEmpty) {
        count++;
      }
    }

    String? error;
    if (passphrase.isEmpty) {
      error = 'Passphrase cannot be empty';
    } else if (count < 4) {
      error = 'Must contain at least four words separated by spaces';
    }

    if (error == null) return true;

    passwordNotifier.value = TextFieldData(
      errorText: error,
      isObscured: passwordNotifier.value.isObscured,
    );

    return false;
  }

  bool _validateResetCode(String code) {
    String? error;
    if (code.isEmpty) {
      error = 'Reset code cannot be empty';
    }

    if (error == null) return true;

    resetCodeNotifier.value = TextFieldData(errorText: error);

    return false;
  }

  void emailChanged(String value) {
    if (emailNotifier.value.hasError) {
      emailNotifier.value = const TextFieldData();
    }
  }

  void passwordChanged(String value) {
    if (passwordNotifier.value.hasError) {
      passwordNotifier.value = TextFieldData(
        errorText: null,
        isObscured: passwordNotifier.value.isObscured,
      );
    }
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

  void showSignUpScreen() {
    screenNotifier.value = AccountScreenType.signUp;
    passwordNotifier.value = const TextFieldData(isObscured: false);
  }

  void forgotPassword() {
    screenNotifier.value = AccountScreenType.forgotPasswordEmail;
  }

  void requestPasswordReset({required String email}) {
    if (!_validateEmail(email)) return;
    screenNotifier.value = AccountScreenType.forgotPasswordVerify;
  }

  void verifyPasswordResetCode({required String code}) {
    if (!_validateResetCode(code)) return;
    screenNotifier.value = AccountScreenType.forgotPasswordNewPassword;
    passwordNotifier.value = const TextFieldData(isObscured: false);
  }

  void resetPassword({required String password}) {}

  void pasteVerificationCode() {}
}
