import 'package:flutter/material.dart';

class SingleLineButton extends StatelessWidget {
  const SingleLineButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = (onPressed == null)
        ? Theme.of(context).disabledColor
        : Theme.of(context).colorScheme.primary;
    final buttonStyle = Theme.of(context).textTheme.labelLarge ?? DefaultTextStyle.of(context).style;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            child: Text(
              title,
              overflow: TextOverflow.clip,
              softWrap: false,
              style: const TextStyle(color: Colors.transparent),
            ),
          ),
        ),
        Center(
          child: IgnorePointer(
            child: Text(
              title,
              softWrap: false,
              style: buttonStyle.copyWith(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
