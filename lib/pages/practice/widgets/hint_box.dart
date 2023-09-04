import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/buttons.dart';

class HintBox extends StatelessWidget {
  const HintBox({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;
  static const _buttonWidth = 100.0;

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
              SizedBox(
                width: _buttonWidth,
                child: ResponseButton(
                  title: 'Letters',
                  onPressed: (enabled) ? manager.showFirstLettersHint : null,
                ),
              ),
              SizedBox(
                width: _buttonWidth,
                child: ResponseButton(
                  title: 'Words',
                  onPressed: (enabled) ? manager.showNextWordHint : null,
                ),
              ),
              if (buttonState.hasCustomHint)
                SizedBox(
                  width: _buttonWidth,
                  child: ResponseButton(
                    title: 'Hint',
                    onPressed: (enabled) ? manager.showCustomHint : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
