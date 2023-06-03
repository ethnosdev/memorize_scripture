import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/add_verse/add_verse_page_manager.dart';

class AddVersePage extends StatefulWidget {
  const AddVersePage({
    super.key,
    required this.collectionId,
    required this.collectionName,
    this.onVerseAdded,
  });

  final String collectionId;
  final String collectionName;
  final void Function()? onVerseAdded;

  @override
  State<AddVersePage> createState() => _AddVersePageState();
}

class _AddVersePageState extends State<AddVersePage> {
  final manager = AddVersePageManager();
  final promptController = TextEditingController();
  final answerController = TextEditingController();
  final promptFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: manager.alreadyExistsNotifier,
                builder: (context, alreadyExists, child) {
                  return TextField(
                    autofocus: true,
                    focusNode: promptFocus,
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
                    onChanged: (value) => manager.onPromptChanged(
                      collectionId: widget.collectionId,
                      prompt: value,
                    ),
                  );
                },
              ),
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
                    onPressed: (canAdd) ? _addVerse : null,
                    child: const Text('Add'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addVerse() async {
    await manager.addVerse(
      collectionId: widget.collectionId,
      prompt: promptController.text,
      answer: answerController.text,
    );
    promptController.text = '';
    answerController.text = '';
    promptFocus.requestFocus();
    widget.onVerseAdded?.call();
  }
}
