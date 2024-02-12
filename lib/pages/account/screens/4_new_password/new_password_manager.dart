import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';

class NewPasswordManager {
  final passwordNotifier = ValueNotifier(
    const TextFieldData(isObscured: false),
  );

  void togglePasswordVisibility() {
    final data = passwordNotifier.value;
    passwordNotifier.value = TextFieldData(
      errorText: data.errorText,
      isObscured: !data.isObscured,
    );
  }

  void onPasswordChanged(String value) {
    if (passwordNotifier.value.hasError) {
      passwordNotifier.value = TextFieldData(
        errorText: null,
        isObscured: passwordNotifier.value.isObscured,
      );
    }
  }

  void resetPassword({required String password}) {}
}
