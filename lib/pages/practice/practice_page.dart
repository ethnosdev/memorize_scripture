import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({
    super.key,
    required this.collection,
  });

  final Collection collection;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final manager = getIt<PracticePageManager>();

  @override
  void initState() {
    super.initState();
    manager.init(
      collectionId: widget.collection.id!,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    manager.textThemeColor = Theme.of(context).textTheme.bodyMedium?.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        collection: widget.collection,
        manager: manager,
      ),
      body: ValueListenableBuilder<PracticeState>(
        valueListenable: manager.uiNotifier,
        builder: (context, value, child) {
          switch (value) {
            case PracticeState.loading:
              return const LoadingIndicator();
            case PracticeState.emptyCollection:
              return const EmptyCollection();
            case PracticeState.practicing:
              return PromptAnswerLayout(manager: manager);
            case PracticeState.finished:
              return const Finished();
          }
        },
      ),
    );
  }
}

class EmptyCollection extends StatelessWidget {
  const EmptyCollection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Press the + button to add a verse.'),
    );
  }
}

class Finished extends StatelessWidget {
  const Finished({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Congratulations! You\'re finished for today!'),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const LinearProgressIndicator(minHeight: 2);
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.collection,
    required this.manager,
  });

  final Collection collection;
  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(collection.name),
      actions: [
        IconButton(
            onPressed: () {
              context.goNamed(
                'add',
                extra: collection,
              );
            },
            icon: const Icon(Icons.add)),
        PopupMenuButton(
          itemBuilder: (context) => [
            if (manager.currentVerseId != null)
              const PopupMenuItem(value: 1, child: Text('Edit')),
            const PopupMenuItem(value: 2, child: Text('View all')),
          ],
          onSelected: (value) {
            debugPrint(value.toString());
            if (value == 1) {
              context.goNamed(
                'edit',
                params: {
                  'verse': manager.currentVerseId!,
                },
                extra: collection,
              );
            } else if (value == 2) {
              context.goNamed(
                'verse_browser',
                extra: collection,
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PromptAnswerLayout extends StatelessWidget {
  const PromptAnswerLayout({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ValueListenableBuilder<String>(
            valueListenable: manager.countNotifier,
            builder: (context, count, child) {
              return Text(count);
            },
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Prompt(manager: manager),
              const SizedBox(height: 20),
              HintBox(manager: manager),
              ValueListenableBuilder<TextSpan>(
                valueListenable: manager.answerNotifier,
                builder: (context, answer, child) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(
                      answer,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: manager.isShowingAnswerNotifier,
          builder: (context, isShowingAnswer, child) {
            if (isShowingAnswer) {
              return ButtonPanel(manager: manager);
            } else {
              return ShowButton(manager: manager);
            }
          },
        ),
      ],
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
              title: 'Again',
              onPressed: () => manager.onResponse(Difficulty.hard),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: 'Tomorrow',
              onPressed: () => manager.onResponse(Difficulty.ok),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: '4 days',
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
    required this.onPressed,
  });

  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Text(title),
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
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: manager.promptNotifier,
      builder: (context, text, child) {
        return Text(text);
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
