import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';
import 'package:memorize_scripture/pages/account/screens/forgot_pw_verify_screen.dart';
import 'package:memorize_scripture/pages/account/screens/signup_screen.dart';

import 'screens/forgot_pw_email_screen.dart';
import 'screens/forgot_pw_new_pw_screen.dart';
import 'screens/signin_screen.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final manager = AccountPageManager();

  @override
  void initState() {
    super.initState();
    manager.onError = _showErrorDialog;
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoginStatus>(
      valueListenable: manager.statusNotifier,
      builder: (context, status, child) {
        switch (status) {
          case LoginStatus.initial:
            return const LoadingOverlay();
          case LoginStatus.loading:
            return LoadingOverlay(
              background: SignUpScreen(manager: manager),
            );
          case LoginStatus.notLoggedIn:
            return NotLoggedInScreen(manager: manager);
          case LoginStatus.loggedIn:
            return const Text('logged in');
        }
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    final okButton = TextButton(
      child: const Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );

    final alert = AlertDialog(
      content: Text(errorMessage),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.background});

  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (background != null) background!,
          AbsorbPointer(
            absorbing: true,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.background.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotLoggedInScreen extends StatelessWidget {
  const NotLoggedInScreen({super.key, required this.manager});

  final AccountPageManager manager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountScreenType>(
      valueListenable: manager.screenNotifier,
      builder: (context, type, child) {
        switch (type) {
          case AccountScreenType.signUp:
            return SignUpScreen(manager: manager);
          case AccountScreenType.signIn:
            return SignInScreen(manager: manager);
          case AccountScreenType.forgotPasswordEmail:
            return ForgotPasswordEmailScreen(manager: manager);
          case AccountScreenType.forgotPasswordVerify:
            return ForgotPasswordVerifyScreen(manager: manager);
          case AccountScreenType.forgotPasswordNewPassword:
            return ForgotPasswordNewPasswordScreen(manager: manager);
        }
      },
    );
  }
}
