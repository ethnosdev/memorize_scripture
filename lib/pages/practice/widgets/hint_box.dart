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
        if (isShowingAnswer) return const HorizontalLine();
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
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
                    OutlinedButton(
                      onPressed: manager.showFirstLettersHint,
                      child: const Text('Letters'),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: manager.showNextWordHint,
                      child: const Text('Words'),
                    ),
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
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HorizontalLine extends StatelessWidget {
  const HorizontalLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      height: 0.5,
      width: 150.0,
      color: Theme.of(context).disabledColor,
    );
  }
}
