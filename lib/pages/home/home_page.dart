import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/drawer.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final manager = getIt<HomePageManager>();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorize Scripture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add collection',
            onPressed: () async {
              final name = await _showEditNameDialog(context);
              manager.addCollection(name);
            },
          ),
          // PopupMenuButton(
          //   itemBuilder: (BuildContext context) => [
          //     const PopupMenuItem(
          //       value: 1,
          //       child: IconTextRow(
          //         icon: Icons.play_arrow,
          //         text: 'Play all',
          //       ),
          //     ),
          //     const PopupMenuItem(
          //       value: 1,
          //       child: IconTextRow(
          //         icon: Icons.sync,
          //         text: 'Sync',
          //       ),
          //     ),
          //     const PopupMenuItem(
          //       value: 1,
          //       child: IconTextRow(
          //         icon: Icons.add,
          //         text: 'Add collection',
          //       ),
          //     ),
          //     const PopupMenuItem(
          //       value: 1,
          //       child: IconTextRow(
          //         icon: Icons.upload,
          //         text: 'Backup',
          //       ),
          //     ),
          //     const PopupMenuItem(
          //       value: 1,
          //       child: IconTextRow(
          //         icon: Icons.download,
          //         text: 'Restore backup',
          //       ),
          //     ),
          //   ],
          //   onSelected: (value) {
          //     // handle menu item selection
          //   },
          // ),
        ],
      ),
      drawer: const MenuDrawer(),
      body: ValueListenableBuilder<List<Collection>>(
        valueListenable: manager.collectionNotifier,
        builder: (context, collections, child) {
          if (collections.isEmpty) {
            return const NoCollections();
          } else {
            return BodyWidget(collections: collections);
          }
        },
      ),
    );
  }
}

class NoCollections extends StatelessWidget {
  const NoCollections({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Press the + button to add a collection.'),
          const SizedBox(height: 50),
          OutlinedButton(
            onPressed: () {
              final url = Uri.parse(AppStrings.tutorialUrl);
              try {
                launchUrl(url);
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            child: const Text('App Tutorial'),
          ),
        ],
      ),
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
    required this.collections,
  });

  final List<Collection> collections;

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  final manager = getIt<HomePageManager>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemCount: widget.collections.length,
        itemBuilder: (context, index) {
          final collection = widget.collections[index];
          return Card(
            key: ValueKey(collection.name),
            child: ListTile(
              title: Text(collection.name),
              onTap: () {
                context.goNamed(
                  RouteName.practice,
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
      ),
    );
  }

  Future<String?> _showCollectionOptionsDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
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
                    RouteName.verseBrowser,
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
                  final newName =
                      await _showEditNameDialog(context, oldName: oldName);
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

    AlertDialog alert = AlertDialog(
      content: const Text('Are you sure you want to delete this collection?'),
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

Future<String?> _showEditNameDialog(
  BuildContext context, {
  String? oldName,
}) async {
  final controller = TextEditingController(text: oldName);
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop(controller.text);
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("Name"),
    content: TextField(
      autofocus: true,
      controller: controller,
    ),
    actions: [okButton],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
