import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/drawer.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorize Scripture'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 1,
                child: IconTextRow(
                  icon: Icons.play_arrow,
                  text: 'Play all',
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconTextRow(
                  icon: Icons.sync,
                  text: 'Sync',
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconTextRow(
                  icon: Icons.upload,
                  text: 'Backup',
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: IconTextRow(
                  icon: Icons.download,
                  text: 'Restore backup',
                ),
              ),
            ],
            onSelected: (value) {
              // handle menu item selection
            },
          ),
        ],
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
          child: ValueListenableBuilder<List<String>>(
              valueListenable: manager.collectionNotifier,
              builder: (context, collectionNames, child) {
                return ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: collectionNames.length,
                  itemBuilder: (context, index) {
                    final name = collectionNames[index];
                    return Card(
                      key: ValueKey(name),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: ListTile(
                          title: Text(name),
                          onTap: () {
                            context.goNamed(
                              'practice',
                              params: {'collection': name},
                            );
                          },
                          onLongPress: () {
                            _showCollectionOptionsDialog(index);
                          },
                        ),
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    manager.onCollectionItemReordered(oldIndex, newIndex);
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
                title: const Text('Rename'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final oldName = manager.collectionNameAt(index);
                  final newName = await _showEditNameDialog(oldName: oldName);
                  manager.renameCollection(index: index, newName: newName);
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
