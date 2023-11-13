import 'package:flutter/material.dart';

class TextFieldData {
  const TextFieldData({
    this.errorText,
    this.isObscured = false,
  });

  final String? errorText;
  final bool isObscured;
  bool get hasError => errorText != null;
}

enum LoginStatus {
  initial,
  loading,
  notLoggedIn,
  loggedIn,
}

class AccountPageManager {
  final emailNotifier = ValueNotifier(const TextFieldData());
  final passwordNotifier = ValueNotifier(const TextFieldData(isObscured: true));
  final statusNotifier = ValueNotifier(LoginStatus.initial);

  void Function(String)? onError;

  Future<void> init() async {
    statusNotifier.value = LoginStatus.initial;
    await Future.delayed(Duration(seconds: 2));
    statusNotifier.value = LoginStatus.notLoggedIn;
  }

  void togglePasswordVisibility() {
    final data = passwordNotifier.value;
    passwordNotifier.value = TextFieldData(
      errorText: data.errorText,
      isObscured: !data.isObscured,
    );
  }

  void createAccount({required String email, required String passphrase}) {
    if (!_emailAndPasswordOk(email, passphrase)) return;
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

  void forgotPassword() {}

  void signInWithGoogle() {}

  void signInWithFacebook() {}

  void signInWithApple() {}

  void showPrivacyPolicy() {}

  void showTermsOfService() {}
}
