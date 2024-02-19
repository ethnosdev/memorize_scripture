import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';
import 'package:memorize_scripture/pages/account/screens/1_sign_up/signup_screen.dart';
import 'package:memorize_scripture/pages/account/screens/3_new_password/new_password_screen.dart';
import 'package:memorize_scripture/pages/account/screens/4_logged_in/logged_in_screen.dart';

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
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountScreenType>(
      valueListenable: manager.screenNotifier,
      builder: (context, status, child) {
        switch (status) {
          case Initial():
            return const Spinner();
          case Loading():
            return const Spinner();
          case SignUp():
            return SignUpScreen(screenNotifier: manager.screenNotifier);
          case SignIn():
            return SignInScreen(
              screenNotifier: manager.screenNotifier,
              email: status.email,
            );
          case NewPassword():
            return NewPasswordScreen(email: status.email);
          case LoggedIn():
            return LoggedInScreen(
              screenNotifier: manager.screenNotifier,
              user: status.user,
            );
        }
      },
    );
  }
}

class Spinner extends StatelessWidget {
  const Spinner({super.key, this.background});

  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: Theme.of(context).colorScheme.background.withOpacity(0.8),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
