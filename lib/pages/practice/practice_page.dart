import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/widgets/loading_screen.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/app_bar.dart';
import 'package:memorize_scripture/pages/practice/widgets/prompt_answer_layout.dart';
import 'package:memorize_scripture/service_locator.dart';

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

  @override
  void initState() {
    super.initState();
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
            case PracticeState.noVersesDue:
              return NoVersesDue(manager: manager);
            case PracticeState.practicing:
              return PromptAnswerLayout(manager: manager);
            case PracticeState.finished:
              return Finished(manager: manager);
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

class NoVersesDue extends StatelessWidget {
  const NoVersesDue({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('There are no more verses due today.'),
          const SizedBox(height: 100),
          OutlinedButton(
            onPressed: manager.practiceAllVerses,
            child: const Text('Practice all verses'),
          ),
        ],
      ),
    );
  }
}

class Finished extends StatelessWidget {
  const Finished({
    super.key,
    required this.manager,
  });

  final PracticePageManager manager;
  static const message = "Congratulations!\nYou're finished for today.";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 100),
          OutlinedButton(
            onPressed: manager.practiceAllVerses,
            child: const Text('Practice all verses'),
          ),
        ],
      ),
    );
  }
}
