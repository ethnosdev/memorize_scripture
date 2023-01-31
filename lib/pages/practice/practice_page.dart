import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/drawer.dart';
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
  @override
  void initState() {
    super.initState();
    getIt<PracticePageManager>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection),
      ),
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          const Text('12'),
          Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Prompt(),
                SizedBox(height: 20),
                HintBox(),
                ValueListenableBuilder<TextSpan>(
                  valueListenable: getIt<PracticePageManager>().answerNotifier,
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
          const ShowButton(),
        ],
      ),
    );
  }
}

class ShowButton extends StatelessWidget {
  const ShowButton({
    super.key,
  });

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
            getIt<PracticePageManager>().show();
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
  });

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Letters'),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () {
                    getIt<PracticePageManager>().showNextWordHint();
                  },
                  child: const Text('Word'),
                ),
              ],
            ),
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
