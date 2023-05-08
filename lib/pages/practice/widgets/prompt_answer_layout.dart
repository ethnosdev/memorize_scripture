import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/button_panel.dart';

// use this to enlarge the text. Later allow the user to adjust this.
const textScaleFactor = 1.2;

class PromptAnswerLayout extends StatelessWidget {
  const PromptAnswerLayout({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Counter(manager: manager),
        Body(manager: manager),
        BottomButtons(manager: manager),
      ],
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: ValueListenableBuilder<String>(
          valueListenable: manager.countNotifier,
          builder: (context, count, child) {
            return Text(count);
          },
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Prompt(manager: manager),
            const SizedBox(height: 20),
            HintBox(manager: manager),
            Answer(manager: manager),
          ],
        ),
      ),
    );
  }
}

class Prompt extends StatelessWidget {
  const Prompt({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: manager.promptNotifier,
      builder: (context, text, child) {
        return SelectableText.rich(
          TextSpan(
            text: text,
          ),
          textAlign: TextAlign.center,
          textScaleFactor: textScaleFactor,
        );
      },
    );
  }
}

class HintBox extends StatelessWidget {
  const HintBox({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).disabledColor,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ValueListenableBuilder<bool>(
                valueListenable: manager.isShowingAnswerNotifier,
                builder: (context, isShowingAnswer, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: (isShowingAnswer)
                            ? null
                            : manager.showFirstLettersHint,
                        child: const Text('Letters'),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed:
                            (isShowingAnswer) ? null : manager.showNextWordHint,
                        child: const Text('Word'),
                      ),
                    ],
                  );
                }),
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
  }
}

class Answer extends StatelessWidget {
  const Answer({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextSpan>(
      valueListenable: manager.answerNotifier,
      builder: (context, answer, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText.rich(
            answer,
            textAlign: TextAlign.center,
            textScaleFactor: textScaleFactor,
          ),
        );
      },
    );
  }
}
