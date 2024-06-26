import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/widgets/syncing_overlay.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';

import 'signin_manager.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.screenNotifier,
    required this.email,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final String email;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInManager manager;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = SignInManager(
      screenNotifier: widget.screenNotifier,
    );
    emailController.text = widget.email;
    manager.onUserNotVerified = _showEmailNotVerifiedDialog;
    manager.onResult = _notifyResult;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: manager.waitingNotifier,
      builder: (context, isProcessing, _) {
        return WaitingOverlay(
          isWaiting: isProcessing,
          child: Scaffold(
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
                      ValueListenableBuilder<String?>(
                        valueListenable: manager.emailNotifier,
                        builder: (context, error, child) {
                          return TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
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
                              autofocus: true,
                              obscureText: data.isObscured,
                              decoration: InputDecoration(
                                labelText: 'Passphrase',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
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
                          }),
                      const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () {
                          manager.signIn(
                            email: emailController.text.toLowerCase(),
                            passphrase: passwordController.text,
                          );
                        },
                        child: const Text('Sign in'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => manager.forgotPassword(
                          emailController.text.toLowerCase(),
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEmailNotVerifiedDialog(String email) {
    const message = 'Your email has not been verified yet. '
        'Please check your email and click the "Verify" button.';

    final okButton = TextButton(
      child: const Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );

    final resendButton = TextButton(
      child: const Text("Resend email"),
      onPressed: () {
        manager.resendEmailVerification(email);
        Navigator.of(context).pop();
      },
    );

    final alert = AlertDialog(
      content: const Text(message),
      actions: [resendButton, okButton],
    );

    showDialog(
      context: context,
      builder: (root) => alert,
    );
  }

  void _notifyResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
