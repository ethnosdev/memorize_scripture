import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                ),
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
                        // Log in logic
                      },
                      child: const Text('Create account'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        // Log in logic
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
