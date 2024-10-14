import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser_manager.dart';

class VerseBrowser extends StatefulWidget {
  const VerseBrowser({
    super.key,
    required this.collection,
    this.onFinished,
  });

  final Collection collection;
  final void Function(String?)? onFinished;

  @override
  State<VerseBrowser> createState() => _VerseBrowserState();
}

class _VerseBrowserState extends State<VerseBrowser> {
  final manager = VerseBrowserManager();

  @override
  void initState() {
    super.initState();
    manager.init(widget.collection.id);
    manager.onFinishedModifyingCollection = widget.onFinished;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, child) {
        final Icon viewIcon;
        switch (manager.viewOptions) {
          case ViewOptions.empty:
            return const SizedBox();
          case ViewOptions.oneColumn:
            viewIcon = const Icon(Icons.grid_view);
          case ViewOptions.twoColumns:
            viewIcon = const Icon(Icons.table_rows_outlined);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.collection.name),
            actions: [
              IconButton(
                icon: viewIcon,
                tooltip: 'Toggle view',
                onPressed: manager.toggleView,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add verse',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditVersePage(
                        collectionId: widget.collection.id,
                        onFinished: manager.onFinishedEditing,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: manager.list.length,
            itemBuilder: (context, index) {
              final verse = manager.list[index];
              if (manager.viewOptions == ViewOptions.oneColumn) {
                return _buildOneColumnTile(verse, context);
              }
              return _buildTwoColumnTile(verse, context);
            },
          ),
        );
      },
    );
  }

  ListTile _buildOneColumnTile(Verse verse, BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.primary;
    return ListTile(
      title: Text.rich(manager.formatText(verse.text, highlightColor)),
      onTap: () => _goEdit(verse),
      onLongPress: () => _showCollectionOptionsDialog(verse),
    );
  }

  ListTile _buildTwoColumnTile(Verse verse, BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.primary;
    const scaler = TextScaler.linear(0.8);
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text.rich(
              manager.formatText(verse.prompt, highlightColor),
              textScaler: scaler,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: manager.formatText(verse.text, highlightColor),
              textScaler: scaler,
            ),
          ),
        ],
      ),
      onTap: () => _goEdit(verse),
      onLongPress: () => _showCollectionOptionsDialog(verse),
    );
  }

  void _goEdit(Verse verse) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditVersePage(
          collectionId: widget.collection.id,
          verseId: verse.id,
          onFinished: manager.onFinishedEditing,
        ),
      ),
    );
  }

  Future<String?> _showCollectionOptionsDialog(Verse verse) async {
    final showMove = manager.shouldShowMoveMenuItem();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Copy verse text'),
                onTap: () {
                  Navigator.of(context).pop();
                  manager.copyVerseText(verse.text);
                },
              ),
              ListTile(
                title: const Text('Reset due date'),
                onTap: () {
                  Navigator.of(context).pop();
                  manager.resetDueDate(verse);
                  _showMessage('Due date reset');
                },
              ),
              if (showMove)
                ListTile(
                  title: const Text('Move'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _showMoveDialog(verse);
                  },
                ),
              ListTile(
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showVerifyDeleteDialog(verse);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showMoveDialog(Verse verse) async {
    final collections = manager.otherCollections();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final name = collections[index].name;
              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.of(context).pop();
                  manager.moveVerse(verse, collections[index].id);
                  _showMessage('Verse moved to $name.');
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<String?> _showVerifyDeleteDialog(Verse verse) async {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget deleteButton = TextButton(
      child: const Text("Delete"),
      onPressed: () {
        Navigator.of(context).pop();
        manager.deleteVerse(verse);
      },
    );

    AlertDialog alert = AlertDialog(
      content: const Text('Are you sure you want to delete this item?'),
      actions: [cancelButton, deleteButton],
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
