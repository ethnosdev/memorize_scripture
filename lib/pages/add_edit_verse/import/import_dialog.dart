import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/book.dart';
import 'package:memorize_scripture/common/version.dart';
import 'package:memorize_scripture/pages/add_edit_verse/import/import_dialog_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/buttons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final manager = ImportDialogManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ValueListenableBuilder<Reference>(
        valueListenable: manager.referenceNotifier,
        builder: (context, reference, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final version = await _showVersionsDialog();
                          if (version?.abbreviation == 'NIV84') {
                            _showNiv84Dialog();
                          } else {
                            manager.setVersion(version);
                          }
                        },
                        child: Text(reference.version),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final book = await _showBooksDialog(reference.book);
                          manager.setBook(book);
                        },
                        child: Text(reference.book),
                      ),
                      if (manager.numberOfChapters > 1)
                        OutlinedButton(
                          onPressed: () async {
                            final number = manager.numberOfChapters;
                            final chapter = await _showChaptersDialog(number);
                            if (chapter == null) return;
                            manager.setChapter(chapter);
                          },
                          child: Text(reference.chapter),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton(
                    onPressed: (!manager.readyToGo)
                        ? null
                        : () {
                            manager.onGoSearchOnlinePressed();
                            Navigator.of(context).pop();
                          },
                    child: const Text('Go'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Version?> _showVersionsDialog() async {
    final versions = manager.availableVersions;
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              return ListTile(
                title: Text(version.name),
                onTap: () => Navigator.of(context).pop(version),
              );
            },
          ),
        );
      },
    );
  }

  Future<Book?> _showBooksDialog(String previouslySelected) async {
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        final otBooks = manager.otBooks;
        final ntBooks = manager.ntBooks;
        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: Row(children: [
            BookList(books: otBooks, selectedBook: previouslySelected),
            BookList(books: ntBooks, selectedBook: previouslySelected),
          ]),
        );
      },
    );
  }

  Future<int?> _showChaptersDialog(int number) async {
    final buttons = List.generate(number, (index) {
      return SizedBox(
        width: 48,
        child: ResponseButton(
          title: '${index + 1}',
          onPressed: () {
            Navigator.of(context).pop(index + 1);
          },
        ),
      );
    });
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 10,
                runSpacing: 10,
                children: buttons,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNiv84Dialog() {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Biblica, the copyright holder, regrettably refuses to grant '
                      'public digital access to the NIV 1984 text. If you have a '
                      'paper version, one workaround for your private use in '
                      'memorization is to take a picture of the '
                      'text with your phone. Long-pressing the image should allow '
                      'you to select the text on most modern phones.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BookList extends StatefulWidget {
  const BookList({
    super.key,
    required this.books,
    required this.selectedBook,
  });

  final List<Book> books;
  final String selectedBook;

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  final itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex();
    });
  }

  void _scrollToIndex() {
    final index =
        widget.books.indexWhere((book) => book.name == widget.selectedBook);
    if (index == -1) return;
    final scrollTo = (index > 0) ? index - 1 : 0;
    itemScrollController.jumpTo(index: scrollTo);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        shrinkWrap: true,
        itemScrollController: itemScrollController,
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final book = widget.books[index];
          return ListTile(
            title: Text(
              book.name,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            onTap: () => Navigator.of(context).pop(book),
          );
        },
      ),
    );
  }
}
