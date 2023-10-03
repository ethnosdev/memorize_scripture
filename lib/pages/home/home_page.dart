import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/home/widgets/drawer.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/common/widgets/icon_text_menu_row.dart';
import 'package:memorize_scripture/common/widgets/loading_screen.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add collection',
            onPressed: () async {
              final name = await _showEditNameDialog(context);
              manager.addCollection(name);
            },
          ),
          Builder(builder: (context) {
            return PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 1,
                  child: IconTextRow(
                    icon: Icons.upload,
                    text: 'Backup',
                  ),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: IconTextRow(
                    icon: Icons.download,
                    text: 'Import',
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 1:
                    final box = context.findRenderObject() as RenderBox?;
                    final rect = box!.localToGlobal(Offset.zero) & box.size;
                    manager.backupCollections(sharePositionOrigin: rect);
                  case 2:
                    manager.import(
                      (message) => _showMessage(context, message),
                    );
                }
              },
            );
          }),
        ],
      ),
      drawer: const MenuDrawer(),
      body: ValueListenableBuilder<HomePageUiState>(
        valueListenable: manager.collectionNotifier,
        builder: (context, uiState, child) {
          switch (uiState) {
            case LoadingCollections():
              return const LoadingIndicator();
            case LoadedCollections(:final list):
              if (list.isEmpty) return const NoCollections();
              return BodyWidget(collections: list);
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
            onPressed: () async {
              final url = Uri.parse(AppStrings.tutorialUrl);
              if (await canLaunchUrl(url)) {
                launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('App Tutorial'),
          ),
        ],
      ),
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
            child: Builder(builder: (listTileContext) {
              return ListTile(
                title: Text(collection.name),
                onTap: () {
                  context.goNamed(
                    RouteName.practice,
                    queryParameters: {
                      Params.colId: collection.id,
                      Params.colName: collection.name,
                    },
                  );
                },
                onLongPress: () {
                  _showCollectionOptionsDialog(listTileContext, index);
                },
              );
            }),
          );
        },
      ),
    );
  }

  Future<String?> _showCollectionOptionsDialog(
    BuildContext listTileContext,
    int index,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Browse verses'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final collection = manager.collectionAt(index);
                  context.goNamed(
                    RouteName.verseBrowser,
                    queryParameters: {
                      Params.colId: collection.id,
                      Params.colName: collection.name,
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Reset due dates'),
                onTap: () {
                  Navigator.of(context).pop();
                  manager.resetDueDates(
                    index: index,
                    onFinished: (count) {
                      _showMessage(
                        context,
                        'Due dates reset on $count verses.',
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Share'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final box = listTileContext.findRenderObject() as RenderBox?;
                  final rect = box!.localToGlobal(Offset.zero) & box.size;
                  await manager.shareCollection(
                    index: index,
                    sharePositionOrigin: rect,
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
      child: const Text("Delete"),
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

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
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
      textCapitalization: TextCapitalization.sentences,
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
