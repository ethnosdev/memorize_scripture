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
    return ValueListenableBuilder<PracticeState>(
      valueListenable: manager.uiNotifier,
      builder: (context, practiceState, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: manager.canUndoNotifier,
          builder: (context, canUndo, child) {
            final title = FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(collectionName),
            );
            switch (practiceState) {
              case PracticeState.loading:
                return AppBar(title: title);

              case PracticeState.emptyCollection:
                return AppBar(
                  title: title,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add verse',
                      onPressed: () => _goAdd(context),
                    ),
                  ],
                );

              case PracticeState.noVersesDue:
              case PracticeState.finished:
                return AppBar(
                  title: title,
                  actions: [
                    if (canUndo) _undoButton(),
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        _addMenuItem(),
                        _verseBrowserMenuItem(),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 3:
                            _goAdd(context);
                          case 4:
                            _goBrowse(context);
                        }
                      },
                    ),
                  ],
                );

              case PracticeState.practicing:
                return AppBar(
                  title: title,
                  actions: [
                    if (canUndo) _undoButton(),
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        _editMenuItem(),
                        if (manager.shouldShowMoveMenuItem) _moveMenuItem(),
                        _addMenuItem(),
                        _verseBrowserMenuItem(),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 1:
                            _goEdit(context);
                          case 2:
                            _showMoveDialog(context);
                          case 3:
                            _goAdd(context);
                          case 4:
                            _goBrowse(context);
                        }
                      },
                    ),
                  ],
                );
            }
          },
        );
      },
    );
  }

  IconButton _undoButton() {
    return IconButton(
      icon: const Icon(Icons.undo),
      tooltip: 'Undo',
      onPressed: manager.undoResponse,
    );
  }

  PopupMenuItem<int> _editMenuItem() {
    return const PopupMenuItem(
      value: 1,
      child: IconTextRow(
        icon: Icons.edit,
        text: 'Edit',
      ),
    );
  }

  PopupMenuItem<int> _moveMenuItem() {
    return const PopupMenuItem(
      value: 2,
      child: IconTextRow(
        icon: Icons.move_down,
        text: 'Move',
      ),
    );
  }

  PopupMenuItem<int> _addMenuItem() {
    return const PopupMenuItem(
      value: 3,
      child: IconTextRow(
        icon: Icons.add,
        text: 'Add verse',
      ),
    );
  }

  PopupMenuItem<int> _verseBrowserMenuItem() {
    return const PopupMenuItem(
      value: 4,
      child: IconTextRow(
        icon: Icons.list,
        text: 'Verse browser',
      ),
    );
  }

  void _goEdit(BuildContext context) {
    context.pushNamed(
      RouteName.edit,
      queryParameters: {
        Params.colId: collectionId,
        Params.colName: collectionName,
        Params.verseId: manager.currentVerseId!,
      },
      extra: manager.onFinishedAddingEditing,
    );
  }

  void _goAdd(BuildContext context) {
    context.pushNamed(
      RouteName.add,
      queryParameters: {
        Params.colId: collectionId,
        Params.colName: collectionName,
      },
      extra: manager.onFinishedAddingEditing,
    );
  }

  void _goBrowse(BuildContext context) {
    context.pushNamed(
      RouteName.verseBrowser,
      queryParameters: {
        Params.colId: collectionId,
        Params.colName: collectionName,
      },
      extra: manager.onFinishedAddingEditing,
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
