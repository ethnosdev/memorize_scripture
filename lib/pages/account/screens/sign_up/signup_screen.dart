import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/dialog/dialog.dart';
import 'package:memorize_scripture/common/widgets/syncing_overlay.dart';
import 'package:memorize_scripture/pages/account/screens/sign_up/signup_manager.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/pages/account/shared/textfield_data.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    required this.screenNotifier,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;

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
      onSuccess: (title, message) => showMessageDialog(
        context: context,
        title: title,
        message: message,
      ),
      onError: _notifyResult,
    );
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
              title: const Text('Sign Up'),
              actions: [
                TextButton(
                  onPressed: () => manager.showSignInScreen(
                    emailController.text.toLowerCase(),
                  ),
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
                            obscureText: data.isObscured,
                            decoration: InputDecoration(
                              labelText: 'Passphrase',
                              hintText: 'Four random words',
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
                        },
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () {
                          manager.createAccount(
                            email: emailController.text.toLowerCase(),
                            passphrase: passwordController.text,
                          );
                        },
                        child: const Text('Create account'),
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
          ),
        );
      },
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
