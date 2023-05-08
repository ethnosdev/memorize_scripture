import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/edit_verse/edit_verse_manager.dart';

class EditVersePage extends StatefulWidget {
  const EditVersePage({
    super.key,
    required this.collectionId,
    required this.verseId,
    this.onFinishedEditing,
  });

  final String collectionId;
  final String verseId;
  final void Function(String?)? onFinishedEditing;

  @override
  State<EditVersePage> createState() => _EditVersePageState();
}

class _EditVersePageState extends State<EditVersePage> {
  final manager = EditVersePageManager();
  final promptController = TextEditingController();
  final answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager.init(
      collectionId: widget.collectionId,
      verseId: widget.verseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              manager.saveVerse(
                prompt: promptController.text,
                answer: answerController.text,
              );
              widget.onFinishedEditing?.call(widget.verseId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<Verse?>(
          valueListenable: manager.verseNotifier,
          builder: (context, verse, child) {
            promptController.text = verse?.prompt ?? '';
            answerController.text = verse?.answer ?? '';
            final due = manager.formatDueDate(verse?.nextDueDate);
            final interval = manager.formatInterval(verse?.interval);
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    controller: promptController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Prompt',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: answerController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).disabledColor,
                            // width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Due: $due'),
                            const SizedBox(height: 4),
                            Text('Interval: $interval'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          manager.softResetProgress(
                            verse?.copyWith(
                              prompt: promptController.text,
                              answer: answerController.text,
                              nextDueDate: null,
                              interval: Duration.zero,
                            ),
                          );
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
