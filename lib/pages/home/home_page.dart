import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/drawer.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorize Scripture'),
        // actions: [
        //   PopupMenuButton(
        //     itemBuilder: (BuildContext context) => [
        //       const PopupMenuItem(
        //         value: 1,
        //         child: IconTextRow(
        //           icon: Icons.play_arrow,
        //           text: 'Play all',
        //         ),
        //       ),
        //       const PopupMenuItem(
        //         value: 1,
        //         child: IconTextRow(
        //           icon: Icons.sync,
        //           text: 'Sync',
        //         ),
        //       ),
        //       const PopupMenuItem(
        //         value: 1,
        //         child: IconTextRow(
        //           icon: Icons.upload,
        //           text: 'Backup',
        //         ),
        //       ),
        //       const PopupMenuItem(
        //         value: 1,
        //         child: IconTextRow(
        //           icon: Icons.download,
        //           text: 'Restore backup',
        //         ),
        //       ),
        //     ],
        //     onSelected: (value) {
        //       // handle menu item selection
        //     },
        //   ),
        // ],
      ),
      drawer: const MenuDrawer(),
      body: const BodyWidget(),
    );
  }
}

class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({
    super.key,
  });

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  final manager = HomePageManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<Collection>>(
              valueListenable: manager.collectionNotifier,
              builder: (context, collections, child) {
                return ListView.builder(
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return Card(
                      key: ValueKey(collection.name),
                      child: ListTile(
                        title: Text(collection.name),
                        onTap: () {
                          context.goNamed(
                            'practice',
                            queryParams: {
                              Params.colId: collection.id,
                              Params.colName: collection.name,
                            },
                          );
                        },
                        onLongPress: () {
                          _showCollectionOptionsDialog(index);
                        },
                      ),
                    );
                  },
                );
              }),
        ),
        OutlinedButton(
          onPressed: () async {
            final name = await _showEditNameDialog();
            manager.addCollection(name);
          },
          child: const Text('Add Collection'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<String?> _showEditNameDialog({String? oldName}) async {
    final controller = TextEditingController(text: oldName);
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop(controller.text);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Name"),
      content: TextField(
        autofocus: true,
        controller: controller,
      ),
      actions: [okButton],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String?> _showCollectionOptionsDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('View'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final collection = manager.collectionAt(index);
                  context.goNamed(
                    'verse_browser',
                    queryParams: {
                      Params.colId: collection.id,
                      Params.colName: collection.name,
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Rename'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final oldName = manager.collectionAt(index).name;
                  final newName = await _showEditNameDialog(oldName: oldName);
                  print('oldName: $oldName, newName: $newName');
                  await manager.renameCollection(
                    index: index,
                    newName: newName,
                  );
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
        manager.deleteCollection(index);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: const Text('Are you sure you want to delete this collection?'),
      actions: [cancelButton, deleteButton],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
