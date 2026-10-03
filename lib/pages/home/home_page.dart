import 'package:flutter/material.dart';
import 'package:memorize_scripture/app_manager.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/account/account_page.dart';
import 'package:memorize_scripture/pages/home/widgets/drawer.dart';
import 'package:memorize_scripture/common/dialog/edit_collection_dialog.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/common/widgets/icon_text_menu_row.dart';
import 'package:memorize_scripture/common/widgets/loading_screen.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/pages/practice/practice_page.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/syncing_overlay.dart';

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
    final fontSizeNotifier = getIt.isRegistered<AppManager>()
        ? getIt<AppManager>().fontSizeNotifier
        : null;
    return ListenableBuilder(
      listenable: Listenable.merge([
        manager.isSyncingNotifier,
        if (fontSizeNotifier != null) fontSizeNotifier,
      ]),
      builder: (context, child) {
        return WaitingOverlay(
          isWaiting: manager.isSyncingNotifier.value,
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add collection',
                  onPressed: () async {
                    final collection =
                        await showEditCollectionDialog(context, manager: manager);
                    if (collection == null) return;
                    manager.addCollection(collection);
                  },
                ),
                Builder(builder: (buttonContext) {
                  return PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 1,
                        child: IconTextRow(
                          icon: Icons.sync,
                          text: 'Sync',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: IconTextRow(
                          icon: Icons.upload,
                          text: 'Backup',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 3,
                        child: IconTextRow(
                          icon: Icons.download,
                          text: 'Import',
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 1:
                          manager.sync(
                            onResult: _notifyResult,
                            onUserNotLoggedIn: _navigateToAccountPage,
                          );
                        case 2:
                          final box = buttonContext.findRenderObject() as RenderBox?;
                          final rect =
                              box!.localToGlobal(Offset.zero) & box.size;
                          manager.backupCollections(sharePositionOrigin: rect);
                        case 3:
                          manager.import(
                            (message) => _showMessage(buttonContext, message),
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
          ),
        );
      },
    );
  }

  void _navigateToAccountPage() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountPage()),
    );
  }

  void _notifyResult(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class NoCollections extends StatelessWidget {
  const NoCollections({super.key});

  Widget _buildContent(double fontSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Press the + button to add a collection.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize * 0.9),
          ),
          const SizedBox(height: 50),
          OutlinedButton(
            onPressed: () async {
              final url = Uri.parse(AppStrings.tutorialUrl);
              if (await canLaunchUrl(url)) {
                launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              'App Tutorial',
              style: TextStyle(fontSize: fontSize * 0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = getIt.isRegistered<AppManager>()
        ? getIt<AppManager>().fontSizeNotifier
        : null;
    double currentFontSize() => getIt.isRegistered<HomePageManager>()
        ? getIt<HomePageManager>().fontSize
        : (getIt.isRegistered<UserSettings>()
            ? getIt<UserSettings>().fontSize
            : UserSettings.defaultFontSize);

    if (fontSizeNotifier == null) {
      return _buildContent(currentFontSize());
    }
    return ListenableBuilder(
      listenable: fontSizeNotifier,
      builder: (context, child) => _buildContent(currentFontSize()),
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

  Widget _buildList(double fontSize) {
    return SafeArea(
      child: ListView.builder(
        itemCount: widget.collections.length,
        itemBuilder: (context, index) {
          final collection = widget.collections[index];
          return Card(
            key: ValueKey(collection.name),
            clipBehavior: Clip.hardEdge,
            child: Builder(builder: (listTileContext) {
              return ListTile(
                title: Text(
                  collection.name,
                  style: TextStyle(fontSize: fontSize * 0.9),
                ),
                trailing: (collection.isPinned) //
                    ? const Icon(Icons.push_pin)
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PracticePage(
                        collection: collection,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  _showCollectionOptionsDialog(
                    listTileContext: listTileContext,
                    index: index,
                    numberOfCollections: widget.collections.length,
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = getIt.isRegistered<AppManager>()
        ? getIt<AppManager>().fontSizeNotifier
        : null;
    if (fontSizeNotifier == null) {
      return _buildList(manager.fontSize);
    }
    return ListenableBuilder(
      listenable: fontSizeNotifier,
      builder: (context, child) => _buildList(manager.fontSize),
    );
  }

  Future<String?> _showCollectionOptionsDialog({
    required BuildContext listTileContext,
    required int index,
    required int numberOfCollections,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        // TODO: refactor methods below to use collection rather than index
        final collection = manager.collectionAt(index);
        final showPinTile = numberOfCollections > 5;
        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (collection.isPinned || showPinTile)
                ListTile(
                  title: (collection.isPinned) //
                      ? const Text('Unpin')
                      : const Text('Pin to top'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    manager.togglePin(collection);
                  },
                ),
              ListTile(
                title: const Text('Browse verses'),
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => VerseBrowser(
                              collection: collection,
                            )),
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
                title: const Text('Edit'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final old = manager.collectionAt(index);
                  final collection = await showEditCollectionDialog(
                    context,
                    manager: manager,
                    oldCollection: old,
                  );
                  if (collection == null) return;
                  await manager.editCollection(collection);
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
      duration: const Duration(seconds: 2),
    ),
  );
}

