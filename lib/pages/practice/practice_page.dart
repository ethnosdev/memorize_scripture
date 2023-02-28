import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({
    super.key,
    required this.collection,
  });

  final String collection;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final manager = getIt<PracticePageManager>();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection),
        actions: [
          IconButton(
              onPressed: () {
                context.goNamed(
                  'add',
                  params: {'collection': widget.collection},
                );
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton(
            itemBuilder: (context) => const [
              PopupMenuItem(value: 1, child: Text('Edit')),
              PopupMenuItem(value: 2, child: Text('View all')),
            ],
            onSelected: (value) {
              debugPrint(value.toString());
            },
          ),
        ],
      ),
      //drawer: const MenuDrawer(),
      body: Stack(
        children: [
          const Text('12'),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Prompt(),
                const SizedBox(height: 20),
                HintBox(manager: manager),
                ValueListenableBuilder<TextSpan>(
                  valueListenable: manager.answerNotifier,
                  builder: (context, answer, child) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: answer,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          ValueListenableBuilder<bool>(
              valueListenable: manager.isShownNotifier,
              builder: (context, isShowingAnswer, child) {
                if (isShowingAnswer) {
                  return ButtonPanel(manager: manager);
                } else {
                  return ShowButton(manager: manager);
                }
              }),
          //ShowButton(manager: manager),
        ],
      ),
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
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('1'),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('2'),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('3'),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('4'),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('5'),
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

class Prompt extends StatelessWidget {
  const Prompt({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      'John 15:1',
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
                valueListenable: manager.isShownNotifier,
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
