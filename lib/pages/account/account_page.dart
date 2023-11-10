import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final manager = AccountPageManager();

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Creating an account allows you '
                    'to save your data online '
                    'and sync devices.'),
                const SizedBox(height: 20),
                ValueListenableBuilder<TextFieldData>(
                    valueListenable: manager.emailNotifier,
                    builder: (context, data, child) {
                      return TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: const OutlineInputBorder(),
                          errorText: data.errorText,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: manager.emailChanged,
                      );
                    }),
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
                        onChanged: manager.passwordChanged,
                      );
                    }),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 8,
                  spacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        manager.createAccount(
                          email: emailController.text,
                          passphrase: passwordController.text,
                        );
                      },
                      child: const Text('Create account'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        manager.login(
                          email: emailController.text,
                          passphrase: passwordController.text,
                        );
                      },
                      child: const Text('Log In'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR'),
                    ),
                    Expanded(
                      child: Divider(thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.google),
                      iconSize: 24.0,
                      onPressed: () {
                        // Google sign-in logic
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.facebook),
                      iconSize: 32.0,
                      onPressed: () {
                        // Facebook sign-in logic
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.apple),
                      iconSize: 32.0,
                      onPressed: () {
                        // Apple sign-in logic
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Privacy policy'),
                    ),
                    TextButton(
                      onPressed: () {},
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
}
