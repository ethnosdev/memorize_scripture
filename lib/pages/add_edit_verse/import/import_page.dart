import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/book.dart';
import 'package:memorize_scripture/common/version.dart';
import 'package:memorize_scripture/pages/add_edit_verse/import/import_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/buttons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final manager = ImportPageManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search online'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ValueListenableBuilder<Reference>(
          valueListenable: manager.referenceNotifier,
          builder: (context, reference, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final version = await _showVersionsDialog();
                        manager.setVersion(version);
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
                    if (reference.chapter != null)
                      OutlinedButton(
                        onPressed: () async {
                          final number = manager.numberOfChapters;
                          final chapter = await _showChaptersDialog(number);
                          if (chapter == null) return;
                          manager.setChapter(chapter);
                        },
                        child: Text(reference.chapter!),
                      ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    onPressed: (manager.readyToGo)
                        ? () async {
                            final url = manager.getUrl();
                            if (url == null) return;
                            if (await canLaunchUrl(url)) {
                              launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        : null,
                    child: const Text('Go'),
                  ),
                ),
                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Version?> _showVersionsDialog() async {
    final versions = manager.availableVersions;
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return Dialog(
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
