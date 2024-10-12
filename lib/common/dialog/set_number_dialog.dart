import 'package:flutter/material.dart';

Future<String?> showSetNumberDialog({
  required BuildContext context,
  required String title,
  required String oldValue,
  required void Function(String) onConfirm,
  required String Function(String) onValidate,
}) async {
  var newValue = oldValue;
  final controller = TextEditingController(text: oldValue);
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      onConfirm(newValue);
      Navigator.of(context).pop(controller.text);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      controller: controller,
      onChanged: (value) {
        newValue = onValidate(value);
      },
      onTap: () {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.value.text.length,
        );
      },
    ),
    actions: [okButton],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
