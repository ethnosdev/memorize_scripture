import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/screens/2_verify_email/verify_email_manager.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.screenNotifier,
    required this.email,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final VerifyEmailManager manager;

  @override
  void initState() {
    super.initState();
    manager = VerifyEmailManager(
      screenNotifier: widget.screenNotifier,
      email: widget.email,
    );
  }

  // TODO: if coming back into focus, check if the
  // clipboard has a code in it.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Your email has not been verified yet. '
                    'Open your email and click the "Verify" button.'),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    manager.verifyEmailDone();
                  },
                  child: const Text('Done'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    manager.resendVerificationEmail();
                  },
                  child: const Text('Resend verification email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
