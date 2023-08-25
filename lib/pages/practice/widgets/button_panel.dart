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
          children: switch (manager.buttonMode) {
            ResponseButtonMode.casualPractice => _casualPracticeButtons(),
            ResponseButtonMode.two => _twoButtons(),
            ResponseButtonMode.four => _fourButtons(),
          },
        ),
      ),
    );
  }

  List<Widget> _casualPracticeButtons() {
    return [
      ResponseButton(
        title: 'Again',
        onPressed: () => manager.onResponse(Difficulty.hard),
      ),
      const SizedBox(width: 5),
      ResponseButton(
        title: 'Good',
        onPressed: () => manager.onResponse(Difficulty.good),
      ),
    ];
  }

  List<Widget> _twoButtons() {
    return [
      ResponseButton(
        title: 'Hard',
        subtitle: manager.hardTitle,
        onPressed: () => manager.onResponse(Difficulty.hard),
      ),
      const SizedBox(width: 5),
      ResponseButton(
        title: 'Good',
        subtitle: manager.goodTitle,
        onPressed: () => manager.onResponse(Difficulty.good),
      ),
    ];
  }

  List<Widget> _fourButtons() {
    return [
      ResponseButton(
        title: 'Hard',
        subtitle: manager.hardTitle,
        onPressed: () => manager.onResponse(Difficulty.hard),
      ),
      const SizedBox(width: 5),
      ResponseButton(
        title: 'OK',
        subtitle: manager.okTitle,
        onPressed: () => manager.onResponse(Difficulty.ok),
      ),
      const SizedBox(width: 5),
      ResponseButton(
        title: 'Good',
        subtitle: manager.goodTitle,
        onPressed: () => manager.onResponse(Difficulty.good),
      ),
      if (manager.shouldShowEasyButton) ...[
        const SizedBox(width: 5),
        ResponseButton(
          title: 'Easy',
          subtitle: manager.easyTitle,
          onPressed: () => manager.onResponse(Difficulty.easy),
        ),
      ]
    ];
  }
}

class ResponseButton extends StatelessWidget {
  const ResponseButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String? subtitle;
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
                    if (subtitle != null)
                      Text(
                        subtitle!,
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
