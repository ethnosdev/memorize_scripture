import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.manager});
  final AccountPageManager manager;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          TextButton(
            onPressed: manager.showSignUpScreen,
            child: const Text('Sign up'),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    manager.login(
                      email: emailController.text,
                      passphrase: passwordController.text,
                    );
                  },
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: manager.forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
