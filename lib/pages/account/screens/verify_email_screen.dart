import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/account_page_manager.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.manager});
  final AccountPageManager manager;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final AccountPageManager manager;
  final codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager = widget.manager;
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
                const Text('Check your email for a verification code.'),
                const SizedBox(height: 20),
                ValueListenableBuilder<TextFieldData>(
                  valueListenable: manager.resetCodeNotifier,
                  builder: (context, data, child) {
                    return TextField(
                      controller: codeController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Verification code',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        errorText: data.errorText,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste),
                          onPressed: manager.pasteVerificationCode,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    );
                  },
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    manager.verifyEmailCode(
                      code: codeController.text,
                    );
                  },
                  child: const Text('Verify code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
