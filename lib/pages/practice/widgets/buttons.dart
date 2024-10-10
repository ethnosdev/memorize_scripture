import 'package:flutter/material.dart';

class ResponseButton extends StatelessWidget {
  const ResponseButton({
    super.key,
    required this.title,
    this.subtitle,
    this.onPressed,
    this.onLongPress,
  });

  final String title;
  final String? subtitle;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          OutlinedButton(
            onPressed: onPressed,
            onLongPress: onLongPress,
            child: const SizedBox(
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Center(
            child: IgnorePointer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style:
                          DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).colorScheme.secondary),
                      textScaler: const TextScaler.linear(0.9),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowButton extends StatelessWidget {
  const ShowButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 48,
        width: double.infinity,
        margin: const EdgeInsets.all(8),
        child: OutlinedButton(
          onPressed: onPressed,
          child: const Text('Show'),
        ),
      ),
    );
  }
}
