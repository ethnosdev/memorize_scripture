import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: manager.isShowingAnswerNotifier,
      builder: (context, isShowingAnswer, child) {
        if (isShowingAnswer) {
          return ButtonPanel(manager: manager);
        } else {
          return ShowButton(manager: manager);
        }
      },
    );
  }
}

class ButtonPanel extends StatelessWidget {
  const ButtonPanel({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 48,
        width: double.infinity,
        margin: const EdgeInsets.all(8),
        child: Row(
          children: [
            ResponseButton(
              title: 'Hard',
              subtitle: manager.hardTitle,
              onPressed: () => manager.onResponse(Difficulty.hard),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: 'So-So',
              subtitle: manager.sosoTitle,
              onPressed: () => manager.onResponse(Difficulty.soso),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: 'Good',
              subtitle: manager.goodTitle,
              onPressed: () => manager.onResponse(Difficulty.good),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: 'Easy',
              subtitle: manager.easyTitle,
              onPressed: () => manager.onResponse(Difficulty.easy),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponseButton extends StatelessWidget {
  const ResponseButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            OutlinedButton(
              onPressed: onPressed,
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
                      style: DefaultTextStyle.of(context).style.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                      subtitle,
                      style: DefaultTextStyle.of(context).style.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      textScaleFactor: 0.9,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowButton extends StatelessWidget {
  const ShowButton({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 48,
        width: double.infinity,
        margin: const EdgeInsets.all(8),
        child: OutlinedButton(
          onPressed: () {
            manager.show();
          },
          child: const Text('Show'),
        ),
      ),
    );
  }
}
