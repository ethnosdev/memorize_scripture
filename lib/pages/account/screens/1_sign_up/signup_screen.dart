import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/screens/1_sign_up/signup_manager.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.screenNotifier,
    // required this.onSignedUp,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  // final void Function(String) onSignedUp;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final SignUpManager manager;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = SignUpManager(
      screenNotifier: widget.screenNotifier,
      onSignedUp: _showMessageDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        actions: [
          TextButton(
            onPressed: manager.showSignInScreen,
            child: const Text('Sign in'),
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
                ValueListenableBuilder<String?>(
                  valueListenable: manager.emailNotifier,
                  builder: (context, error, child) {
                    return TextField(
                      controller: emailController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        errorText: error,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: manager.onEmailChanged,
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
                      onChanged: manager.onPasswordChanged,
                    );
                  },
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<bool>(
                  valueListenable: manager.waitingNotifier,
                  builder: (context, isProcessing, _) {
                    if (isProcessing) {
                      return const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(),
                      );
                    }
                    return OutlinedButton(
                      onPressed: () {
                        manager.createAccount(
                          email: emailController.text,
                          passphrase: passwordController.text,
                        );
                      },
                      child: const Text('Create account'),
                    );
                  },
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
      ),
    );
  }

  void _showMessageDialog(String message) {
    final okButton = TextButton(
      child: const Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );

    final alert = AlertDialog(
      content: Text(message),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }
}
