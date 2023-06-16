import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    return ValueListenableBuilder<PracticeState>(
      valueListenable: manager.uiNotifier,
      builder: (context, practiceState, child) {
        return AppBar(
          title: Text(collectionName),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.goNamed(
                  RouteName.add,
                  queryParams: {
                    Params.colId: collectionId,
                    Params.colName: collectionName,
                  },
                  extra: manager.onFinishedAddingEditing,
                );
              },
            ),
            if (practiceState == PracticeState.practicing)
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1, child: Text('Edit')),
                ],
                onSelected: (value) {
                  debugPrint(value.toString());
                  if (value == 1) {
                    context.goNamed(
                      RouteName.editPractice,
                      queryParams: {
                        Params.colId: collectionId,
                        Params.colName: collectionName,
                        Params.verseId: manager.currentVerseId!,
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
