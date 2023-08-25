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
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed:
                    (isShowingAnswer) ? null : manager.showFirstLettersHint,
                child: const Text('Letters'),
              ),
              OutlinedButton(
                onPressed: (isShowingAnswer) ? null : manager.showNextWordHint,
                child: const Text('Words'),
              ),
              if (manager.verseHasHint)
                OutlinedButton(
                  onPressed: (isShowingAnswer) ? null : manager.showCustomHint,
                  child: const Text('Hint'),
                ),
            ],
          ),
        );
      },
    );
  }
}
