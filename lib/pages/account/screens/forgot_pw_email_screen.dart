import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key, required this.manager});
  final AccountPageManager manager;

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  late final AccountPageManager manager;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = widget.manager;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ValueListenableBuilder<TextFieldData>(
                  valueListenable: manager.emailNotifier,
                  builder: (context, data, child) {
                    return TextField(
                      controller: emailController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        errorText: data.errorText,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: manager.emailChanged,
                    );
                  },
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    manager.requestPasswordReset(
                      email: emailController.text,
                    );
                  },
                  child: const Text('Request password reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
