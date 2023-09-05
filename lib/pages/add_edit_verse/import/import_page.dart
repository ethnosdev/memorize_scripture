import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/book.dart';
import 'package:memorize_scripture/common/version.dart';
import 'package:memorize_scripture/pages/add_edit_verse/import/import_page_manager.dart';
import 'package:memorize_scripture/pages/practice/widgets/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final manager = ImportPageManager();
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
                        final book = await _showBooksDialog();
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

  Future<Book?> _showBooksDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        final otBooks = manager.otBooks;
        final ntBooks = manager.ntBooks;
        return Dialog(
          child: Row(children: [
            BookList(books: otBooks),
            BookList(books: ntBooks),
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

class BookList extends StatelessWidget {
  const BookList({
    super.key,
    required this.books,
  });

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
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
