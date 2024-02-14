import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/screens/3_new_password/new_password_manager.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});
  // final AccountPageManager manager;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late final NewPasswordManager manager;
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = NewPasswordManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ValueListenableBuilder<TextFieldData>(
                  valueListenable: manager.passwordNotifier,
                  builder: (context, data, child) {
                    return TextField(
                      controller: passwordController,
                      autofocus: true,
                      obscureText: data.isObscured,
                      decoration: InputDecoration(
                        labelText: 'Enter a new passphrase',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: manager.togglePasswordVisibility,
                          icon: (data.isObscured)
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        hintText: 'Four random words',
                        errorText: data.errorText,
                        errorMaxLines: 3,
                      ),
                      onChanged: manager.onPasswordChanged,
                    );
                  },
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    manager.resetPassword(
                      password: passwordController.text,
                    );
                  },
                  child: const Text('Reset password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
