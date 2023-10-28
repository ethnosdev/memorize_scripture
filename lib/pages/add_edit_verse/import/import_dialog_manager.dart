import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/book.dart';
import 'package:memorize_scripture/common/version.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/book_data/bible_data.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportDialogManager {
  final referenceNotifier = ValueNotifier<Reference>(const Reference());
  final bibleData = getIt<BibleData>();
  final userSettings = getIt<UserSettings>();

  Future<void> init() async {
    final (version, book, chapter) = userSettings.getRecentReference();
    if (version != null) {
      _currentVersion = bibleData
          .fetchAvailableVersions()
          .firstWhere((v) => v.abbreviation == version);
    }
    if (book != null) {
      _currentBook = bibleData.fetchBooks().firstWhere((b) => b.name == book);
    }
    _currentChapter = chapter;
    referenceNotifier.value = Reference(
      version: _currentVersion?.name ?? Reference.defaultVersion,
      book: _currentBook?.name ?? Reference.defaultBook,
      chapter: _currentChapter?.toString() ?? Reference.defaultChapter,
    );
  }

  List<Version> get availableVersions {
    return bibleData.fetchAvailableVersions();
  }

  List<Book> get otBooks => bibleData.fetchOtBooks();
  List<Book> get ntBooks => bibleData.fetchNtBooks();

  int get numberOfChapters => _currentBook?.numberChapters ?? 1;

  Version? _currentVersion;
  Book? _currentBook;
  int? _currentChapter;

  get readyToGo => _currentVersion != null && _currentBook != null;

  void setVersion(Version? version) {
    if (version == null) return;
    _currentVersion = version;
    userSettings.setRecentReference(
      version: _currentVersion?.abbreviation,
      book: _currentBook?.name,
      chapter: _currentChapter,
    );
    referenceNotifier.value = referenceNotifier.value.copyWith(
      version: version.name,
    );
  }

  void setBook(Book? book) {
    if (book == null) return;
    _currentBook = book;
    final savedChapter = userSettings.getChapterForBook(book.name);
    _currentChapter = (book.numberChapters == 1) ? null : savedChapter;
    userSettings.setRecentReference(
      version: _currentVersion?.abbreviation,
      book: _currentBook?.name,
      chapter: _currentChapter,
    );
    referenceNotifier.value = referenceNotifier.value.copyWith(
      book: book.name,
      chapter: _currentChapter?.toString(),
    );
  }

  void setChapter(int chapter) {
    _currentChapter = chapter;
    userSettings.setRecentReference(
      version: _currentVersion?.abbreviation,
      book: _currentBook?.name,
      chapter: _currentChapter,
    );
    if (_currentBook != null) {
      userSettings.setChapterForBook(_currentBook!.name, chapter);
    }
    referenceNotifier.value = referenceNotifier.value.copyWith(
      chapter: chapter.toString(),
    );
  }

  Future<void> onGoSearchOnlinePressed() async {
    final url = _getUrl();
    if (url == null) return;
    if (await canLaunchUrl(url)) {
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Uri? _getUrl() {
    final chapter = _currentChapter ?? 1;
    if (_currentBook == null) return null;
    return _currentVersion?.generateUrl(_currentBook!, chapter);
  }
}

class Reference {
  static const defaultVersion = 'Version';
  static const defaultBook = 'Book';
  static const defaultChapter = '1';

  const Reference({
    this.version = defaultVersion,
    this.book = defaultBook,
    this.chapter = defaultChapter,
  });

  final String version;
  final String book;
  final String chapter;

  static const _nullSentinel = 'null';

  Reference copyWith({
    String? version = _nullSentinel,
    String? book = _nullSentinel,
    String? chapter = _nullSentinel,
  }) {
    return Reference(
      version:
          (version != _nullSentinel) ? version ?? defaultVersion : this.version,
      book: (book != _nullSentinel) ? book ?? defaultBook : this.book,
      chapter:
          (chapter != _nullSentinel) ? chapter ?? defaultChapter : this.chapter,
    );
  }
}
