import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/edit_verse/edit_verse_manager.dart';

class EditVersePage extends StatefulWidget {
  const EditVersePage({
    super.key,
    required this.collectionId,
    required this.verseId,
  });

  final String collectionId;
  final String verseId;

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
        title: Text(widget.collectionId),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<Verse?>(
          valueListenable: manager.verseNotifier,
          builder: (context, verse, child) {
            promptController.text = verse?.prompt ?? '';
            answerController.text = verse?.answer ?? '';
            return Column(
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
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    manager.saveVerse(
                      prompt: promptController.text,
                      answer: answerController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
