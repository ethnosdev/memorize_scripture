import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.manager});
  final AccountPageManager manager;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final AccountPageManager manager;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = widget.manager;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Creating an account allows you '
                  'to save your data online '
                  'and sync devices.'),
              const SizedBox(height: 20),
              ValueListenableBuilder<TextFieldData>(
                valueListenable: manager.emailNotifier,
                builder: (context, data, child) {
                  return TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
                      errorText: data.errorText,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: manager.emailChanged,
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextFieldData>(
                  valueListenable: manager.passwordNotifier,
                  builder: (context, data, child) {
                    return TextField(
                      controller: passwordController,
                      obscureText: data.isObscured,
                      decoration: InputDecoration(
                        labelText: 'Passphrase',
                        hintText: 'Four random words',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: manager.togglePasswordVisibility,
                          icon: (data.isObscured)
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        errorText: data.errorText,
                        errorMaxLines: 3,
                      ),
                      onChanged: manager.passwordChanged,
                    );
                  }),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: manager.forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                runSpacing: 8,
                spacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      manager.createAccount(
                        email: emailController.text,
                        passphrase: passwordController.text,
                      );
                    },
                    child: const Text('Create account'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      manager.login(
                        email: emailController.text,
                        passphrase: passwordController.text,
                      );
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: manager.showPrivacyPolicy,
                    child: const Text('Privacy policy'),
                  ),
                  TextButton(
                    onPressed: manager.showTermsOfService,
                    child: const Text('Terms of Service'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
