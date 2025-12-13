import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/button_panel.dart';
import 'package:memorize_scripture/pages/practice/widgets/hint_box.dart';

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
    return SafeArea(
      child: Column(
        children: [
          Counter(manager: manager),
          Body(manager: manager),
          BottomButtons(manager: manager),
        ],
      ),
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
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Prompt(manager: manager),
                const SizedBox(height: 10),
                HintBox(manager: manager),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Answer(manager: manager),
          ),
        ],
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
    return ValueListenableBuilder<TextSpan>(
      valueListenable: manager.promptNotifier,
      builder: (context, text, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SelectableText.rich(
            text,
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(textScaleFactor),
          ),
        );
      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ValueListenableBuilder<AnswerType>(
        valueListenable: manager.answerNotifier,
        builder: (context, answer, child) {
          switch (answer) {
            case NoAnswer():
              return GestureDetector(
                onTap: manager.showNextWordHint,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 200,
                  color: Colors.transparent,
                ),
              );
            case CustomHint():
            case FinalAnswer():
            case LettersHint():
              return Align(
                alignment: Alignment.topCenter,
                child: SelectableText.rich(
                  answer.textSpan,
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(textScaleFactor),
                ),
              );
            case WordsHint():
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  SelectableText.rich(
                    answer.textSpan,
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(textScaleFactor),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: manager.showNextWordHint,
                      behavior: HitTestBehavior.opaque,
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
