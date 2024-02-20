import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/dialog/dialog.dart';
import 'package:memorize_scripture/pages/account/screens/3_new_password/new_password_manager.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({
    super.key,
    required this.screenNotifier,
    required this.email,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;
  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  late final NewPasswordManager manager;
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = NewPasswordManager(
      screenNotifier: widget.screenNotifier,
      onResetSent: (title, message) => showMessageDialog(
        context: context,
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton(
                    onPressed: () {
                      manager.resetPassword(email: widget.email);
                    },
                    child: const Text('Reset password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
