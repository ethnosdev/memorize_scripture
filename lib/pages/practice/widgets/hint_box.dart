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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed:
                    (isShowingAnswer) ? null : manager.showFirstLettersHint,
                child: const Text('Letters'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: (isShowingAnswer) ? null : manager.showNextWordHint,
                child: const Text('Words'),
              ),
            ],
          ),
        );
      },
    );
  }
}
