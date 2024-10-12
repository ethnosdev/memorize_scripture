import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/buttons.dart';

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
          return ShowButton(onPressed: manager.show);
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
            children: switch (manager.practiceMode) {
          PracticeMode.reviewBySpacedRepetition => _spacedRepetitionButtons(),
          PracticeMode.reviewByFixedDays => _fixedDaysButtons(),
          PracticeMode.reviewSameNumberPerDay => _plainButtons(),
          PracticeMode.casualPractice => _plainButtons(),
        }),
      ),
    );
  }

  List<Widget> _spacedRepetitionButtons() {
    return [
      Expanded(
        child: ResponseButton(
          title: 'Hard',
          subtitle: manager.hardTitle,
          onPressed: () => manager.onResponse(Difficulty.hard),
          onLongPress: () => manager.onResponse(Difficulty.ok),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'Good',
          subtitle: manager.goodTitle,
          onPressed: () => manager.onResponse(Difficulty.good),
          onLongPress: () => manager.onResponse(Difficulty.easy),
        ),
      ),
    ];
  }

  List<Widget> _fixedDaysButtons() {
    return [
      Expanded(
        child: ResponseButton(
          title: 'Hard',
          subtitle: manager.hardTitle,
          onPressed: () => manager.onResponse(Difficulty.hard),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'OK',
          subtitle: manager.okTitle,
          onPressed: () => manager.onResponse(Difficulty.ok),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'Good',
          subtitle: manager.goodTitle,
          onPressed: () => manager.onResponse(Difficulty.good),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'Easy',
          subtitle: manager.easyTitle,
          onPressed: () => manager.onResponse(Difficulty.easy),
        ),
      ),
    ];
  }

  List<Widget> _plainButtons() {
    return [
      Expanded(
        child: ResponseButton(
          title: 'Again',
          onPressed: () => manager.onResponse(Difficulty.hard),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'Good',
          onPressed: () => manager.onResponse(Difficulty.good),
        ),
      ),
    ];
  }
}
