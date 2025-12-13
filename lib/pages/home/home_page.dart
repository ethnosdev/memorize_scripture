import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/account/account_page.dart';
import 'package:memorize_scripture/pages/home/widgets/drawer.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/common/widgets/icon_text_menu_row.dart';
import 'package:memorize_scripture/common/widgets/loading_screen.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/pages/practice/practice_page.dart';
import 'package:memorize_scripture/pages/verse_browser/verse_browser.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

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
    return ValueListenableBuilder<bool>(
      valueListenable: manager.isSyncingNotifier,
      builder: (context, isSyncing, child) {
        return WaitingOverlay(
          isWaiting: isSyncing,
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add collection',
                  onPressed: () async {
                    final collection =
                        await _showEditNameDialog(context, manager);
                    if (collection == null) return;
                    manager.addCollection(collection);
                  },
                ),
                Builder(builder: (context) {
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
                            onUserNotLoggedIn: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AccountPage()),
                              );
                            },
                          );
                        case 2:
                          final box = context.findRenderObject() as RenderBox?;
                          final rect =
                              box!.localToGlobal(Offset.zero) & box.size;
                          manager.backupCollections(sharePositionOrigin: rect);
                        case 3:
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
          ),
        );
      },
    );
  }

  void _notifyResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
          const Text(
            'Press the + button to add a collection.',
            textAlign: TextAlign.center,
          ),
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
                  final collection = await _showEditNameDialog(
                    context,
                    manager,
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

Future<Collection?> _showEditNameDialog(
  BuildContext context,
  HomePageManager manager, {
  Collection? oldCollection,
}) async {
  final oldName = oldCollection?.name;
  final nameController = TextEditingController(text: oldName);
  StudyStyle studyStyle =
      oldCollection?.studyStyle ?? StudyStyle.spacedRepetition;

  // Same number per day
  final versesPerDay =
      oldCollection?.versesPerDay ?? Collection.defaultVersesPerDay;
  final versesPerDayController =
      TextEditingController(text: versesPerDay.toString());

  // Fixed days
  final goodDaysController = TextEditingController(text: manager.fixedGoodDays);
  final easyDaysController = TextEditingController(text: manager.fixedEasyDays);

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Collection"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: oldName == null,
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StudyStyle>(
                    isExpanded: true,
                    initialValue: studyStyle,
                    items: const [
                      DropdownMenuItem(
                        value: StudyStyle.spacedRepetition,
                        child: Text('Spaced repetition'),
                      ),
                      DropdownMenuItem(
                        value: StudyStyle.fixedDays,
                        child: Text('Choose frequency'),
                      ),
                      DropdownMenuItem(
                        value: StudyStyle.sameNumberPerDay,
                        child: Text('Fixed number of verses'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        studyStyle = value!;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Review style'),
                  ),
                  if (studyStyle != StudyStyle.spacedRepetition)
                    const SizedBox(height: 16),
                  if (studyStyle == StudyStyle.sameNumberPerDay)
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: versesPerDayController,
                      decoration: const InputDecoration(
                        labelText: 'Verses per day',
                      ),
                    ),
                  if (studyStyle == StudyStyle.fixedDays) ...[
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: goodDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Days for Good',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: easyDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Days for Easy',
                      ),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: nameController.text.isEmpty
                    ? null
                    : () {
                        manager.fixedGoodDays = goodDaysController.text;
                        manager.fixedEasyDays = easyDaysController.text;
                        Navigator.of(context).pop(
                          Collection(
                            id: oldCollection?.id ?? const Uuid().v4(),
                            name: nameController.text,
                            studyStyle: studyStyle,
                            versesPerDay:
                                int.tryParse(versesPerDayController.text) ??
                                    Collection.defaultVersesPerDay,
                            createdDate:
                                oldCollection?.createdDate ?? DateTime.now(),
                          ),
                        );
                      },
                child: const Text("OK"),
              )
            ],
          );
        },
      );
    },
  );
}
