import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';
import 'package:memorize_scripture/pages/account/screens/1_sign_up/signup_screen.dart';
import 'package:memorize_scripture/pages/account/screens/3_new_password/new_password_screen.dart';

import 'screens/2_sign_in/signin_screen.dart';
import 'shared/account_screen_type.dart';

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
    // manager.onEventCompletion = _showMessageDialog;
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
              background: SignUpScreen(
                screenNotifier: manager.screenNotifier,
                // onSignedUp: _showMessageDialog,
              ),
            );
          case LoginStatus.notLoggedIn:
            return NotLoggedInScreen(manager: manager);
          case LoginStatus.loggedIn:
            return const Text('logged in');
        }
      },
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
            return SignUpScreen(
              screenNotifier: manager.screenNotifier,
              // onSignedUp: _showMessageDialog,
            );
          // case AccountScreenType.verifyEmail:
          //   return VerifyEmailScreen(
          //     screenNotifier: manager.screenNotifier,
          //   );
          case AccountScreenType.signIn:
            return SignInScreen(
              screenNotifier: manager.screenNotifier,
            );
          case AccountScreenType.newPassword:
            return NewPasswordScreen();
        }
      },
    );
  }
}
