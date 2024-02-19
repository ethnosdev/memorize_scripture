import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';

import 'logged_in_manager.dart';

class LoggedInScreen extends StatefulWidget {
  const LoggedInScreen({
    super.key,
    required this.screenNotifier,
  });
  final ValueNotifier<AccountScreenType> screenNotifier;

  @override
  State<LoggedInScreen> createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  late final LoggedInManager manager;

  @override
  void initState() {
    super.initState();
    manager = LoggedInManager(
      screenNotifier: widget.screenNotifier,
    );
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const Text('Signed in as'),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                      valueListenable: manager.emailNotifier,
                      builder: (context, email, child) {
                        return Text(
                          email,
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      }),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Sync verses'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed: manager.signOut,
                      child: const Text('Sign out'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed: _showVerifyDeleteDialog,
                      child: const Text('Delete account'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVerifyDeleteDialog() async {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget deleteButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop();
        manager.deleteAccount();
      },
    );

    AlertDialog alert = AlertDialog(
      content: const Text(
        'Are you sure you want to delete your account?\n\n'
        'This will only delete your user profile and online data. '
        'If you wish to also delete the verse collections on this device, '
        'you can uninstall the app.',
      ),
      actions: [cancelButton, deleteButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}