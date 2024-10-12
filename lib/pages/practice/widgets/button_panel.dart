import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/dialog/set_number_dialog.dart';
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

class ButtonPanel extends StatefulWidget {
  const ButtonPanel({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  State<ButtonPanel> createState() => _ButtonPanelState();
}

class _ButtonPanelState extends State<ButtonPanel> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 48,
        width: double.infinity,
        margin: const EdgeInsets.all(8),
        child: Row(
            children: switch (widget.manager.practiceMode) {
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
          subtitle: widget.manager.hardTitle,
          onPressed: () => widget.manager.onResponse(Difficulty.hard),
          onLongPress: () => widget.manager.onResponse(Difficulty.ok),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'Good',
          subtitle: widget.manager.goodTitle,
          onPressed: () => widget.manager.onResponse(Difficulty.good),
          onLongPress: () => widget.manager.onResponse(Difficulty.easy),
        ),
      ),
    ];
  }

  List<Widget> _fixedDaysButtons() {
    return [
      Expanded(
        child: ResponseButton(
          title: 'Hard',
          subtitle: widget.manager.hardTitle,
          onPressed: () => widget.manager.onResponse(Difficulty.hard),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'OK',
          subtitle: widget.manager.okTitle,
          onPressed: () => widget.manager.onResponse(Difficulty.ok),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ValueListenableBuilder<String>(
            valueListenable: widget.manager.goodTitleNotifier,
            builder: (context, goodTitle, child) {
              return ResponseButton(
                title: 'Good',
                subtitle: goodTitle,
                onPressed: () => widget.manager.onResponse(Difficulty.good),
                onLongPress: () async {
                  await showSetNumberDialog(
                    context: context,
                    title: 'Set days for Good',
                    oldValue: widget.manager.fixedGoodDays,
                    onValidate: widget.manager.validateFixedGoodDays,
                    onConfirm: widget.manager.updateFixedGoodDays,
                  );
                },
              );
            }),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ValueListenableBuilder<String>(
            valueListenable: widget.manager.easyTitleNotifier,
            builder: (context, easyTitle, child) {
              return ResponseButton(
                  title: 'Easy',
                  subtitle: easyTitle,
                  onPressed: () => widget.manager.onResponse(Difficulty.easy),
                  onLongPress: () async {
                    await showSetNumberDialog(
                      context: context,
                      title: 'Set days for Easy',
                      oldValue: widget.manager.fixedEasyDays,
                      onValidate: widget.manager.validateFixedEasyDays,
                      onConfirm: widget.manager.updateFixedEasyDays,
                    );
                    setState(() {});
                  });
            }),
      ),
    ];
  }

  List<Widget> _plainButtons() {
    return [
      Expanded(
        child: ResponseButton(
          title: 'Again',
          onPressed: () => widget.manager.onResponse(Difficulty.hard),
        ),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: ResponseButton(
          title: 'Good',
          onPressed: () => widget.manager.onResponse(Difficulty.good),
        ),
      ),
    ];
  }
}
