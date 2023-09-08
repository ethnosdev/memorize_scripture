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
            if (!isPracticing)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add verse',
                onPressed: () {
                  context.goNamed(
                    RouteName.addPractice,
                    queryParameters: {
                      Params.colId: collectionId,
                      Params.colName: collectionName,
                    },
                    extra: manager.onFinishedAddingEditing,
                  );
                },
              ),
            if (isPracticing)
              PopupMenuButton(
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: IconTextRow(
                      icon: Icons.edit,
                      text: 'Edit',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: IconTextRow(
                      icon: Icons.add,
                      text: 'Add verse',
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      context.goNamed(
                        RouteName.editPractice,
                        queryParameters: {
                          Params.colId: collectionId,
                          Params.colName: collectionName,
                          Params.verseId: manager.currentVerseId!,
                        },
                        extra: manager.onFinishedAddingEditing,
                      );
                    case 2:
                      context.goNamed(
                        RouteName.addPractice,
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
