import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';
import 'package:memorize_scripture/pages/account/screens/signup_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ValueListenableBuilder<LoginStatus>(
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
              return SignUpScreen(manager: manager);
            case LoginStatus.loggedIn:
              return const Text('logged in');
          }
        },
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.background});

  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }
}
