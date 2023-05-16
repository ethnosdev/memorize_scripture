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
    return ValueListenableBuilder<bool>(
      valueListenable: manager.isShowingAnswerNotifier,
      builder: (context, isShowingAnswer, child) {
        final lettersButton = OutlinedButton(
          onPressed: (isShowingAnswer) ? null : manager.showFirstLettersHint,
          child: const Text('Letters'),
        );
        final wordsButton = OutlinedButton(
          onPressed: (isShowingAnswer) ? null : manager.showNextWordHint,
          child: const Text('Word'),
        );
        final outlineColor = (isShowingAnswer)
            ? Theme.of(context).disabledColor
            : Theme.of(context).colorScheme.outline;
        final labelStyle = Theme.of(context).textTheme.labelSmall;
        final hintStyle = (isShowingAnswer)
            ? labelStyle?.copyWith(color: Theme.of(context).disabledColor)
            : labelStyle;
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: outlineColor,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    lettersButton,
                    const SizedBox(width: 20),
                    wordsButton,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 3,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Text(
                  'Hints',
                  style: hintStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
