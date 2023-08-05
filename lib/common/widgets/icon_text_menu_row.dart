import 'package:flutter/material.dart';

class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
