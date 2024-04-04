import 'package:flutter/material.dart';

class WaitingOverlay extends StatelessWidget {
  const WaitingOverlay({
    super.key,
    required this.isWaiting,
    required this.child,
  });

  final bool isWaiting;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isWaiting) return child;
    return Stack(
      children: [
        child,
        Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
