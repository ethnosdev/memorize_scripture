import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/widgets/icon_text_menu_row.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.manager,
    required this.collectionId,
    required this.collectionName,
  });

  final PracticePageManager manager;
  final String collectionId;
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<(bool, bool)>(
      valueListenable: manager.appBarNotifier,
      builder: (context, value, child) {
        final (isPracticing, canUndo) = value;
        return AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(collectionName),
          ),
          actions: [
            if (canUndo)
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: manager.undoResponse,
              ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                if (isPracticing)
                  const PopupMenuItem(
                    value: 1,
                    child: IconTextRow(
                      icon: Icons.edit,
                      text: 'Edit',
                    ),
                  ),
                if (isPracticing && manager.shouldShowMoveMenuItem)
                  const PopupMenuItem(
                    value: 2,
                    child: IconTextRow(
                      icon: Icons.move_down,
                      text: 'Move',
                    ),
                  ),
                const PopupMenuItem(
                  value: 3,
                  child: IconTextRow(
                    icon: Icons.add,
                    text: 'Add verse',
                  ),
                ),
                const PopupMenuItem(
                  value: 4,
                  child: IconTextRow(
                    icon: Icons.list,
                    text: 'Verse browser',
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 1:
                    context.pushNamed(
                      RouteName.edit,
                      queryParameters: {
                        Params.colId: collectionId,
                        Params.colName: collectionName,
                        Params.verseId: manager.currentVerseId!,
                      },
                      extra: manager.onFinishedAddingEditing,
                    );
                  case 2:
                    _showMoveDialog(context);
                  case 3:
                    context.pushNamed(
                      RouteName.add,
                      queryParameters: {
                        Params.colId: collectionId,
                        Params.colName: collectionName,
                      },
                      extra: manager.onFinishedAddingEditing,
                    );
                  case 4:
                    context.pushNamed(
                      RouteName.verseBrowser,
                      queryParameters: {
                        Params.colId: collectionId,
                        Params.colName: collectionName,
                      },
                      extra: manager.onFinishedAddingEditing,
                    );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showMoveDialog(BuildContext context) async {
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
                  manager.moveVerse(collections[index].id);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
