import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser_manager.dart';

class VerseBrowser extends StatefulWidget {
  const VerseBrowser({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  final String collectionId;
  final String collectionName;

  @override
  State<VerseBrowser> createState() => _VerseBrowserState();
}

class _VerseBrowserState extends State<VerseBrowser> {
  final manager = VerseBrowserManager();

  @override
  void initState() {
    super.initState();
    manager.init(widget.collectionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
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
                  final verse = manager.verseFor(index);
                  context.goNamed(
                    RouteName.editBrowser,
                    queryParameters: {
                      Params.colId: widget.collectionId,
                      Params.colName: widget.collectionName,
                      Params.verseId: verse.id,
                    },
                    extra: manager.onFinishedEditing,
                  );
                },
                onLongPress: () async {
                  _showCollectionOptionsDialog(index);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _showCollectionOptionsDialog(int index) async {
    final showMove = manager.shouldShowMoveMenuItem();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (showMove)
                ListTile(
                  title: const Text('Move'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _showMoveDialog(index: index);
                  },
                ),
              ListTile(
                title: const Text('Reset due date'),
                onTap: () {
                  Navigator.of(context).pop();
                  manager.resetDueDate(index: index);
                  _showMessage('Due date reset');
                },
              ),
              ListTile(
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showVerifyDeleteDialog(index: index);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showMoveDialog({required int index}) async {
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
                  manager.moveVerse(index, collections[index].id);
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

  Future<String?> _showVerifyDeleteDialog({required int index}) async {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget deleteButton = TextButton(
      child: const Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        manager.deleteVerse(index);
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
