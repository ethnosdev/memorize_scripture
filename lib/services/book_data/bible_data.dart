import 'package:memorize_scripture/common/book.dart';
import 'package:memorize_scripture/common/version.dart';

class BibleData {
  /// Returns a list of the available Bible versions to import.
  List<Version> fetchAvailableVersions() => _versions;

  List<Book> fetchOtBooks() {
    return _books.where((book) => book.testament == Testament.ot).toList();
  }

  List<Book> fetchNtBooks() {
    return _books.where((book) => book.testament == Testament.nt).toList();
  }

  List<Book> fetchBooks() => _books;
}

Uri _biblePortalUrl(Book book, int chapter, String version) {
  final sanitizedBook = book.name.replaceAll(' ', '+');
  final url = 'https://bibleportal.com/passage'
      '?search=$sanitizedBook+$chapter'
      '&version=$version';
  return Uri.parse(url);
}

final _versions = [
  Version(
    name: 'ESV',
    longName: 'English Standard Version',
    abbreviation: 'ESV',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'ESV'),
  ),
  Version(
    name: 'KJV',
    longName: 'King James Version',
    abbreviation: 'KJV',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'KJV'),
  ),
  Version(
    name: 'NKJV',
    longName: 'New King James Version',
    abbreviation: 'NKJV',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'NKJV'),
  ),
  Version(
    name: 'NLT',
    longName: 'New Living Translation',
    abbreviation: 'NLT',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'NLT'),
  ),
  Version(
    name: 'NIV 1984',
    longName: 'New International Version (1984)',
    abbreviation: 'NIV84',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'NIV1984'),
  ),
  Version(
    name: 'NIV 2011',
    longName: 'New International Version (2011)',
    abbreviation: 'NIV11',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'NIV'),
  ),
  Version(
    name: 'WEB',
    longName: 'World English Bible',
    abbreviation: 'WEB',
    generateUrl: (book, chapter) => _biblePortalUrl(book, chapter, 'WEB'),
  ),
];

final _books = [
  // Old Testament
  Book(
      id: 1,
      abbreviation: 'gen',
      name: 'Genesis',
      numberChapters: 50,
      testament: Testament.ot),
  Book(
      id: 2,
      abbreviation: 'exo',
      name: 'Exodus',
      numberChapters: 40,
      testament: Testament.ot),
  Book(
      id: 3,
      abbreviation: 'lev',
      name: 'Leviticus',
      numberChapters: 27,
      testament: Testament.ot),
  Book(
      id: 4,
      abbreviation: 'num',
      name: 'Numbers',
      numberChapters: 36,
      testament: Testament.ot),
  Book(
      id: 5,
      abbreviation: 'deu',
      name: 'Deuteronomy',
      numberChapters: 34,
      testament: Testament.ot),
  Book(
      id: 6,
      abbreviation: 'jos',
      name: 'Joshua',
      numberChapters: 24,
      testament: Testament.ot),
  Book(
      id: 7,
      abbreviation: 'jdg',
      name: 'Judges',
      numberChapters: 21,
      testament: Testament.ot),
  Book(
      id: 8,
      abbreviation: 'rut',
      name: 'Ruth',
      numberChapters: 4,
      testament: Testament.ot),
  Book(
      id: 9,
      abbreviation: '1sa',
      name: '1 Samuel',
      numberChapters: 31,
      testament: Testament.ot),
  Book(
      id: 10,
      abbreviation: '2sa',
      name: '2 Samuel',
      numberChapters: 24,
      testament: Testament.ot),
  Book(
      id: 11,
      abbreviation: '1ki',
      name: '1 Kings',
      numberChapters: 22,
      testament: Testament.ot),
  Book(
      id: 12,
      abbreviation: '2ki',
      name: '2 Kings',
      numberChapters: 25,
      testament: Testament.ot),
  Book(
      id: 13,
      abbreviation: '1ch',
      name: '1 Chronicles',
      numberChapters: 29,
      testament: Testament.ot),
  Book(
      id: 14,
      abbreviation: '2ch',
      name: '2 Chronicles',
      numberChapters: 36,
      testament: Testament.ot),
  Book(
      id: 15,
      abbreviation: 'ezr',
      name: 'Ezra',
      numberChapters: 10,
      testament: Testament.ot),
  Book(
      id: 16,
      abbreviation: 'neh',
      name: 'Nehemiah',
      numberChapters: 13,
      testament: Testament.ot),
  Book(
      id: 17,
      abbreviation: 'est',
      name: 'Esther',
      numberChapters: 10,
      testament: Testament.ot),
  Book(
      id: 18,
      abbreviation: 'job',
      name: 'Job',
      numberChapters: 42,
      testament: Testament.ot),
  Book(
      id: 19,
      abbreviation: 'psa',
      name: 'Psalms',
      numberChapters: 150,
      testament: Testament.ot),
  Book(
      id: 20,
      abbreviation: 'pro',
      name: 'Proverbs',
      numberChapters: 31,
      testament: Testament.ot),
  Book(
      id: 21,
      abbreviation: 'ecc',
      name: 'Ecclesiastes',
      numberChapters: 12,
      testament: Testament.ot),
  Book(
      id: 22,
      abbreviation: 'sng',
      name: 'Song of Solomon',
      numberChapters: 8,
      testament: Testament.ot),
  Book(
      id: 23,
      abbreviation: 'isa',
      name: 'Isaiah',
      numberChapters: 66,
      testament: Testament.ot),
  Book(
      id: 24,
      abbreviation: 'jer',
      name: 'Jeremiah',
      numberChapters: 52,
      testament: Testament.ot),
  Book(
      id: 25,
      abbreviation: 'lam',
      name: 'Lamentations',
      numberChapters: 5,
      testament: Testament.ot),
  Book(
      id: 26,
      abbreviation: 'ezk',
      name: 'Ezekiel',
      numberChapters: 48,
      testament: Testament.ot),
  Book(
      id: 27,
      abbreviation: 'dan',
      name: 'Daniel',
      numberChapters: 12,
      testament: Testament.ot),
  Book(
      id: 28,
      abbreviation: 'hos',
      name: 'Hosea',
      numberChapters: 14,
      testament: Testament.ot),
  Book(
      id: 29,
      abbreviation: 'joe',
      name: 'Joel',
      numberChapters: 3,
      testament: Testament.ot),
  Book(
      id: 30,
      abbreviation: 'amo',
      name: 'Amos',
      numberChapters: 9,
      testament: Testament.ot),
  Book(
      id: 31,
      abbreviation: 'oba',
      name: 'Obadiah',
      numberChapters: 1,
      testament: Testament.ot),
  Book(
      id: 32,
      abbreviation: 'jon',
      name: 'Jonah',
      numberChapters: 4,
      testament: Testament.ot),
  Book(
      id: 33,
      abbreviation: 'mic',
      name: 'Micah',
      numberChapters: 7,
      testament: Testament.ot),
  Book(
      id: 34,
      abbreviation: 'nam',
      name: 'Nahum',
      numberChapters: 3,
      testament: Testament.ot),
  Book(
      id: 35,
      abbreviation: 'hab',
      name: 'Habakkuk',
      numberChapters: 3,
      testament: Testament.ot),
  Book(
      id: 36,
      abbreviation: 'zep',
      name: 'Zephaniah',
      numberChapters: 3,
      testament: Testament.ot),
  Book(
      id: 37,
      abbreviation: 'hag',
      name: 'Haggai',
      numberChapters: 2,
      testament: Testament.ot),
  Book(
      id: 38,
      abbreviation: 'zec',
      name: 'Zechariah',
      numberChapters: 14,
      testament: Testament.ot),
  Book(
      id: 39,
      abbreviation: 'mal',
      name: 'Malachi',
      numberChapters: 4,
      testament: Testament.ot),

  // New Testament
  Book(
      id: 41,
      abbreviation: 'mat',
      name: 'Matthew',
      numberChapters: 28,
      testament: Testament.nt),
  Book(
      id: 42,
      abbreviation: 'mar',
      name: 'Mark',
      numberChapters: 16,
      testament: Testament.nt),
  Book(
      id: 43,
      abbreviation: 'luk',
      name: 'Luke',
      numberChapters: 24,
      testament: Testament.nt),
  Book(
      id: 44,
      abbreviation: 'joh',
      name: 'John',
      numberChapters: 21,
      testament: Testament.nt),
  Book(
      id: 45,
      abbreviation: 'act',
      name: 'Acts',
      numberChapters: 28,
      testament: Testament.nt),
  Book(
      id: 46,
      abbreviation: 'rom',
      name: 'Romans',
      numberChapters: 16,
      testament: Testament.nt),
  Book(
      id: 47,
      abbreviation: '1co',
      name: '1 Corinthians',
      numberChapters: 16,
      testament: Testament.nt),
  Book(
      id: 48,
      abbreviation: '2co',
      name: '2 Corinthians',
      numberChapters: 13,
      testament: Testament.nt),
  Book(
      id: 49,
      abbreviation: 'gal',
      name: 'Galatians',
      numberChapters: 6,
      testament: Testament.nt),
  Book(
      id: 50,
      abbreviation: 'eph',
      name: 'Ephesians',
      numberChapters: 6,
      testament: Testament.nt),
  Book(
      id: 51,
      abbreviation: 'phi',
      name: 'Philippians',
      numberChapters: 4,
      testament: Testament.nt),
  Book(
      id: 52,
      abbreviation: 'col',
      name: 'Colossians',
      numberChapters: 4,
      testament: Testament.nt),
  Book(
      id: 53,
      abbreviation: '1th',
      name: '1 Thessalonians',
      numberChapters: 5,
      testament: Testament.nt),
  Book(
      id: 54,
      abbreviation: '2th',
      name: '2 Thessalonians',
      numberChapters: 3,
      testament: Testament.nt),
  Book(
      id: 55,
      abbreviation: '1ti',
      name: '1 Timothy',
      numberChapters: 6,
      testament: Testament.nt),
  Book(
      id: 56,
      abbreviation: '2ti',
      name: '2 Timothy',
      numberChapters: 4,
      testament: Testament.nt),
  Book(
      id: 57,
      abbreviation: 'tit',
      name: 'Titus',
      numberChapters: 3,
      testament: Testament.nt),
  Book(
      id: 58,
      abbreviation: 'phm',
      name: 'Philemon',
      numberChapters: 1,
      testament: Testament.nt),
  Book(
      id: 59,
      abbreviation: 'heb',
      name: 'Hebrews',
      numberChapters: 13,
      testament: Testament.nt),
  Book(
      id: 60,
      abbreviation: 'jas',
      name: 'James',
      numberChapters: 5,
      testament: Testament.nt),
  Book(
      id: 61,
      abbreviation: '1pe',
      name: '1 Peter',
      numberChapters: 5,
      testament: Testament.nt),
  Book(
      id: 62,
      abbreviation: '2pe',
      name: '2 Peter',
      numberChapters: 3,
      testament: Testament.nt),
  Book(
      id: 63,
      abbreviation: '1jo',
      name: '1 John',
      numberChapters: 5,
      testament: Testament.nt),
  Book(
      id: 64,
      abbreviation: '2jo',
      name: '2 John',
      numberChapters: 1,
      testament: Testament.nt),
  Book(
      id: 65,
      abbreviation: '3jo',
      name: '3 John',
      numberChapters: 1,
      testament: Testament.nt),
  Book(
      id: 66,
      abbreviation: 'jud',
      name: 'Jude',
      numberChapters: 1,
      testament: Testament.nt),
  Book(
      id: 67,
      abbreviation: 'rev',
      name: 'Revelation',
      numberChapters: 22,
      testament: Testament.nt),
];
