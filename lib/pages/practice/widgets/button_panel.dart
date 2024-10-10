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
          children: (manager.practiceMode == PracticeMode.reviewByDueDate) //
              ? _buttonsWithDate()
              : _plainButtons(),
        ),
      ),
    );
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

  List<Widget> _buttonsWithDate() {
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
}
