import 'package:flutter/material.dart';

class SyncingOverlay extends StatelessWidget {
  const SyncingOverlay({
    super.key,
    required this.isSyncing,
    required this.child,
  });

  final bool isSyncing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isSyncing) return child;
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
