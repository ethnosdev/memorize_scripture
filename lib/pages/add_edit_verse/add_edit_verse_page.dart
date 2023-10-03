import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page_manager.dart';
import 'package:memorize_scripture/pages/add_edit_verse/import/import_dialog.dart';

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
  final verseTextFocus = FocusNode();
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
              await _saveVerse();
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
                  if (!isEditing) _searchOnline(context),
                  const SizedBox(height: 10),
                  _prompt(),
                  const SizedBox(height: 10),
                  _verseText(),
                  const SizedBox(height: 10),
                  _hintOption(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomKeyboardAction(
            icon: Icons.format_bold,
            onTap: _highlight,
          ),
          CustomKeyboardAction(
            icon: Icons.keyboard_arrow_left,
            onTap: _moveLeft,
          ),
          CustomKeyboardAction(
            icon: Icons.keyboard_arrow_right,
            onTap: _moveRight,
          ),
          CustomKeyboardAction(
            icon: Icons.copy,
            onTap: _copy,
          ),
          CustomKeyboardAction(
            icon: Icons.paste,
            onTap: _paste,
          ),
        ],
      ),
    );
  }

  TextEditingController? _getFocusedController() {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == promptFocus) {
      return promptController;
    } else if (currentFocus == verseTextFocus) {
      return verseTextController;
    } else if (currentFocus == hintFocus) {
      return hintController;
    }
    return null;
  }

  void _highlight() {
    final controller = _getFocusedController();
    if (controller == null || !controller.selection.isValid) return;
    var text = controller.text;
    final start = controller.selection.start;
    final end = controller.selection.end;
    final (newText, index) = manager.updateHighlight(text, start, end);
    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: index);
    if (controller == promptController) {
      manager.onPromptChanged(newText);
    } else if (controller == verseTextController) {
      manager.onVerseTextChanged(newText);
    } else if (controller == hintController) {
      manager.onHintChanged(newText);
    }
  }

  void _moveLeft() => _moveCursor(-1);

  void _moveRight() => _moveCursor(1);

  void _moveCursor(int step) {
    final controller = _getFocusedController();
    if (controller == null || !controller.selection.isValid) return;
    final cursorPos = (step.isNegative)
        ? controller.selection.start
        : controller.selection.end;
    if (!controller.selection.isCollapsed) {
      controller.selection = TextSelection.collapsed(offset: cursorPos);
      return;
    }
    if ((step.isNegative && cursorPos <= 0) ||
        (!step.isNegative && cursorPos >= controller.text.length)) {
      return;
    }
    controller.selection = TextSelection.collapsed(offset: cursorPos + step);
  }

  Future<void> _copy() async {
    final controller = _getFocusedController();
    if (controller == null ||
        !controller.selection.isValid ||
        controller.text.isEmpty) {
      return;
    }
    // if there is no selection, select everything
    final finalPosition = controller.selection.end;
    if (controller.selection.isCollapsed) {
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // copy selection
    final selectedText = controller.text.substring(
      controller.selection.start,
      controller.selection.end,
    );
    Clipboard.setData(ClipboardData(text: selectedText));
    // collapse selection
    controller.selection = TextSelection.collapsed(offset: finalPosition);
  }

  Future<void> _paste() async {
    final controller = _getFocusedController();
    // get clipboard text and check it
    if (controller == null || !controller.selection.isValid) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = _removeExtraSpaces(data?.text);
    if (text.isEmpty) return;
    // get selection
    final start = controller.selection.start;
    final end = controller.selection.end;
    final before = controller.text.substring(0, start);
    final after = controller.text.substring(end);
    // insert at or replace selection
    var newText = before + text + after;
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: start + text.length,
    );
    if (controller == promptController) {
      manager.onPromptChanged(newText);
    } else if (controller == verseTextController) {
      manager.onVerseTextChanged(newText);
    } else if (controller == hintController) {
      manager.onHintChanged(newText);
    }
  }

  String _removeExtraSpaces(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r' +'), ' ').trim();
  }

  Align _searchOnline(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: OutlinedButton(
        child: const Text('Search online'),
        onPressed: () => _showSearchOnlineDialog(),
      ),
    );
  }

  ValueListenableBuilder<bool> _prompt() {
    return ValueListenableBuilder<bool>(
      valueListenable: manager.alreadyExistsNotifier,
      builder: (context, alreadyExists, child) {
        return TextField(
          autofocus: !isEditing,
          focusNode: promptFocus,
          controller: promptController,
          textCapitalization: TextCapitalization.sentences,
          maxLines: null,
          decoration: InputDecoration(
            labelText: 'Prompt',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            errorText: (alreadyExists) ? 'This prompt already exists' : null,
          ),
          onChanged: manager.onPromptChanged,
        );
      },
    );
  }

  TextField _verseText() {
    return TextField(
      focusNode: verseTextFocus,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
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
      onChanged: manager.onVerseTextChanged,
    );
  }

  ValueListenableBuilder<bool> _hintOption() {
    return ValueListenableBuilder<bool>(
      valueListenable: manager.showHintBoxNotifier,
      builder: (context, showHintBox, child) {
        if (showHintBox || hintController.text.isNotEmpty) {
          return TextField(
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
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

  Future<void> _showSearchOnlineDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return const ImportDialog();
      },
    );
  }
}

class CustomKeyboardAction extends StatelessWidget {
  const CustomKeyboardAction({
    super.key,
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          icon,
          size: 24,
        ),
      ),
    );
  }
}
