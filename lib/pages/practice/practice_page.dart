import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';

// use this to enlarge the text. Later allow the user to adjust this.
const textScaleFactor = 1.2;

class PracticePage extends StatefulWidget {
  const PracticePage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  final String collectionId;
  final String collectionName;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final manager = getIt<PracticePageManager>();
  //late Collection collection;

  @override
  void initState() {
    super.initState();
    // collection = Collection(
    //   id: widget.collectionId,
    //   name: widget.collectionName,
    // );
    manager.init(collectionId: widget.collectionId);
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
        manager: manager,
        collectionId: widget.collectionId,
        collectionName: widget.collectionName,
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
    required this.manager,
    required this.collectionId,
    required this.collectionName,
  });

  final PracticePageManager manager;
  final String collectionId;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(collectionName),
      actions: [
        IconButton(
            onPressed: () {
              context.goNamed(
                'add',
                queryParams: {
                  Params.colId: collectionId,
                  Params.colName: collectionName,
                },
              );
            },
            icon: const Icon(Icons.add)),
        PopupMenuButton(
          itemBuilder: (context) => [
            if (manager.currentVerseId != null)
              const PopupMenuItem(value: 1, child: Text('Edit')),
          ],
          onSelected: (value) {
            debugPrint(value.toString());
            if (value == 1) {
              context.goNamed(
                'edit',
                queryParams: {
                  Params.colId: collectionId,
                  Params.colName: collectionName,
                  Params.verseId: manager.currentVerseId!,
                },
                extra: manager.onFinishedEditing,
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
                      textScaleFactor: textScaleFactor,
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
              title: manager.hardTitle,
              onPressed: () => manager.onResponse(Difficulty.hard),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: manager.okTitle,
              onPressed: () => manager.onResponse(Difficulty.ok),
            ),
            const SizedBox(width: 5),
            ResponseButton(
              title: manager.easyTitle,
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
        return Text.rich(
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
