import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/book.dart';
import 'package:memorize_scripture/common/version.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/book_data/bible_data.dart';

class ImportPageManager {
  final referenceNotifier = ValueNotifier<Reference>(const Reference());
  final bibleData = getIt<BibleData>();

  List<Version> get availableVersions {
    return bibleData.fetchAvailableVersions();
  }

  List<Book> get otBooks => bibleData.fetchOtBooks();
  List<Book> get ntBooks => bibleData.fetchNtBooks();

  int get numberOfChapters => _currentBook?.numberChapters ?? 1;

  Version? _currentVersion;
  Book? _currentBook;
  int? _currentChapter;

  get readyToGo =>
      _currentVersion != null &&
      _currentBook != null &&
      _currentChapter != null;

  void setVersion(Version? version) {
    _currentVersion = version;
    referenceNotifier.value = referenceNotifier.value.copyWith(
      version: version?.name,
    );
  }

  void setBook(Book? book) {
    _currentBook = book;
    _currentChapter = (book?.numberChapters == 1) ? null : 1;
    referenceNotifier.value = referenceNotifier.value.copyWith(
      book: book?.name,
      chapter: _currentChapter?.toString(),
    );
  }

  void setChapter(int chapter) {
    _currentChapter = chapter;
    referenceNotifier.value = referenceNotifier.value.copyWith(
      chapter: chapter.toString(),
    );
  }

  Uri? getUrl() {
    if (_currentBook == null || _currentChapter == null) return null;
    return _currentVersion?.generateUrl(_currentBook!, _currentChapter!);
  }
}

class Reference {
  const Reference({
    this.version = 'Version',
    this.book = 'Book',
    this.chapter,
  });

  final String version;
  final String book;
  final String? chapter;

  static const _nullSentinel = 'null';

  Reference copyWith({
    String? version,
    String? book,
    String? chapter = _nullSentinel,
  }) {
    return Reference(
      version: version ?? this.version,
      book: book ?? this.book,
      chapter: (chapter != _nullSentinel) ? chapter : this.chapter,
    );
  }
}
