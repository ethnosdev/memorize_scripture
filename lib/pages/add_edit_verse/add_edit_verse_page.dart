import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page_manager.dart';

class AddEditVersePage extends StatefulWidget {
  const AddEditVersePage({
    super.key,
    required this.collectionId,
    this.verseId,
    this.onFinished,
  });

  final String collectionId;
  final String? verseId;
  final void Function(String?)? onFinished;

  @override
  State<AddEditVersePage> createState() => _AddEditVersePageState();
}

class _AddEditVersePageState extends State<AddEditVersePage> {
  final manager = AddEditVersePageManager();
  final promptController = TextEditingController();
  final verseTextController = TextEditingController();
  final hintController = TextEditingController();
  final promptFocus = FocusNode();
  final hintFocus = FocusNode();

  bool get isEditing => widget.verseId != null;

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
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () async {
            if (!manager.hasUnsavedChanges) {
              Navigator.pop(context);
              return;
            }
            final shouldSave = await _showShouldSaveDialog() ?? false;
            if (shouldSave) {
              _saveVerse();
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: (isEditing) ? const Text('Edit verse') : const Text('Add verse'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: manager.canAddNotifier,
            builder: (context, canAdd, child) {
              return IconButton(
                icon: const Icon(Icons.done),
                onPressed: (canAdd) ? _saveVerse : null,
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Verse?>(
        valueListenable: manager.verseNotifier,
        builder: (context, verse, child) {
          promptController.text = verse?.prompt ?? '';
          verseTextController.text = verse?.text ?? '';
          hintController.text = verse?.hint ?? '';
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: manager.alreadyExistsNotifier,
                    builder: (context, alreadyExists, child) {
                      return TextField(
                        autofocus: !isEditing,
                        focusNode: promptFocus,
                        controller: promptController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Prompt',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          errorText: (alreadyExists)
                              ? 'This prompt already exists'
                              : null,
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
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 5,
                    controller: verseTextController,
                    decoration: const InputDecoration(
                      labelText: 'Verse text',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                    ),
                    onChanged: manager.onAnswerChanged,
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<bool>(
                    valueListenable: manager.showHintBoxNotifier,
                    builder: (context, showHintBox, child) {
                      if (showHintBox || hintController.text.isNotEmpty) {
                        return TextField(
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 5,
                          focusNode: hintFocus,
                          controller: hintController,
                          decoration: const InputDecoration(
                            labelText: 'Hint',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                          ),
                          onChanged: manager.onHintChanged,
                        );
                      }
                      return OutlinedButton(
                        onPressed: () {
                          manager.onAddHintButtonPressed();
                          hintFocus.requestFocus();
                        },
                        child: const Text('Add hint'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveVerse() async {
    if (isEditing) {
      Navigator.of(context).pop();
      await manager.updateVerse(
        verseId: widget.verseId!,
        prompt: promptController.text,
        text: verseTextController.text,
        hint: hintController.text,
      );
    } else {
      await manager.addVerse(
        prompt: promptController.text,
        verseText: verseTextController.text,
        hint: hintController.text,
      );
      promptController.text = '';
      verseTextController.text = '';
      hintController.text = '';
      promptFocus.requestFocus();
      _showMessage('Verse added');
    }
    widget.onFinished?.call(widget.verseId);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<bool?> _showShouldSaveDialog() async {
    Widget saveButton = TextButton(
      child: const Text('Save'),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );

    Widget discardButton = TextButton(
      child: const Text(
        "Discard",
      ),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );

    AlertDialog alert = AlertDialog(
      content: const Text('You have unsaved changes.'),
      actions: [discardButton, saveButton],
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
