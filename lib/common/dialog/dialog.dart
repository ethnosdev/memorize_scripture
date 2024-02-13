import 'package:flutter/material.dart';

void showMessageDialog({
  required BuildContext context,
  String? title,
  required String message,
}) {
  final root = context.findRootAncestorStateOfType<NavigatorState>()!.context;
  final okButton = TextButton(
    child: const Text("OK"),
    onPressed: () => Navigator.of(root).pop(),
  );

  final alert = AlertDialog(
    title: title == null ? null : Text(title),
    content: Text(message),
    actions: [okButton],
  );

  showDialog(
    context: root,
    builder: (root) => alert,
  );
}
