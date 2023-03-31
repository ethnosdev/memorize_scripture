import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/add_verse/add_verse_page_manager.dart';

class AddVersePage extends StatefulWidget {
  const AddVersePage({
    super.key,
    required this.collection,
  });

  final Collection collection;

  @override
  State<AddVersePage> createState() => _AddVersePageState();
}

class _AddVersePageState extends State<AddVersePage> {
  final manager = AddVersePageManager();
  final promptController = TextEditingController();
  final answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
                valueListenable: manager.alreadyExistsNotifier,
                builder: (context, alreadyExists, child) {
                  return TextField(
                    autofocus: true,
                    controller: promptController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Prompt',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      errorText:
                          (alreadyExists) ? 'This prompt already exists' : null,
                    ),
                    onChanged: manager.onPromptChanged,
                  );
                }),
            const SizedBox(height: 10),
            TextField(
              maxLines: 5,
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
              ),
              onChanged: manager.onAnswerChanged,
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
                valueListenable: manager.canAddNotifier,
                builder: (context, canAdd, child) {
                  return OutlinedButton(
                    onPressed: (canAdd)
                        ? () {
                            manager.addVerse(
                              collectionId: widget.collection.id!,
                              prompt: promptController.text,
                              answer: answerController.text,
                            );
                            promptController.text = '';
                            answerController.text = '';
                          }
                        : null,
                    child: const Text('Add'),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
