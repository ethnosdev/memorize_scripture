import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';

class HintBox extends StatelessWidget {
  const HintBox({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HintButtonState>(
      valueListenable: manager.hintButtonNotifier,
      builder: (context, buttonState, child) {
        final enabled = buttonState.isEnabled;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: (enabled) ? manager.showFirstLettersHint : null,
                child: const Text('Letters'),
              ),
              OutlinedButton(
                onPressed: (enabled) ? manager.showNextWordHint : null,
                child: const Text('Words'),
              ),
              if (buttonState.hasCustomHint)
                OutlinedButton(
                  onPressed: (enabled) ? manager.showCustomHint : null,
                  child: const Text('Hint'),
                ),
            ],
          ),
        );
      },
    );
  }
}
