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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: [
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
      body: ValueListenableBuilder(
        valueListenable: manager.listNotifier,
        builder: (context, list, child) {
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final verse = list[index];
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                        child: Text(
                      verse.prompt,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      verse.text,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditVersePage(
                        collectionId: widget.collection.id,
                        verseId: verse.id,
                        onFinished: manager.onFinishedEditing,
                      ),
                    ),
                  );
                },
                onLongPress: () => _showCollectionOptionsDialog(verse),
              );
            },
          );
        },
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
