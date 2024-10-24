import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';

void sortCollectionsBiblically(List<Collection> list) {
  list.sort((a, b) {
    // sort pinned before others
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;

    // try to parse the collection name as a reference
    final aRef = parseReference(a.name);
    final bRef = parseReference(b.name);
    if (aRef == null || bRef == null) {
      return a.name.compareTo(b.name);
    }
    // sort by biblical reference
    final result = aRef.compareTo(bRef);
    if (result != 0) return result;
    // if the references are the same then sort by whole name
    return a.name.compareTo(b.name);
  });
}

void sortVersesBiblically(List<Verse> list) {
  list.sort((a, b) {
    // sort new verses before old verses
    if (a.isNew && !b.isNew) return -1;
    if (!a.isNew && b.isNew) return 1;
    // try to parse the prompt beginning as a reference
    final aRef = parseReference(a.prompt);
    final bRef = parseReference(b.prompt);
    if (aRef == null || bRef == null) {
      return a.prompt.compareTo(b.prompt);
    }
    // sort by biblical reference
    final result = aRef.compareTo(bRef);
    if (result != 0) return result;
    // if the references are the same then sort by whole prompt
    return a.prompt.compareTo(b.prompt);
  });
}

class Reference implements Comparable<Reference> {
  Reference({
    required this.book,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
  });
  final String book;
  final int? startChapter;
  final int? startVerse;
  final int? endChapter;
  final int? endVerse;

  @override
  int compareTo(Reference other) {
    final thisIndex = _bookOrderMap[book.toLowerCase()];
    final otherIndex = _bookOrderMap[other.book.toLowerCase()];
    if (thisIndex == null || otherIndex == null) {
      // sort recognized references before others
      if (otherIndex != null) return 1;
      if (thisIndex != null) return -1;
      // if both invalid then sort alphabetically
      return book.compareTo(other.book);
    }

    if (thisIndex != otherIndex) {
      return thisIndex.compareTo(otherIndex);
    }

    if (startChapter != other.startChapter) {
      if (startChapter == null) return -1;
      if (other.startChapter == null) return 1;
      return startChapter!.compareTo(other.startChapter!);
    }

    if (startVerse != other.startVerse) {
      if (startVerse == null) return -1;
      if (other.startVerse == null) return 1;
      return startVerse!.compareTo(other.startVerse!);
    }

    if (endChapter != other.endChapter) {
      if (endChapter == null) return -1;
      if (other.endChapter == null) return 1;
      return endChapter!.compareTo(other.endChapter!);
    }

    if (endVerse != other.endVerse) {
      if (endVerse == null) return -1;
      if (other.endVerse == null) return 1;
      return endVerse!.compareTo(other.endVerse!);
    }

    return 0;
  }
}

@visibleForTesting
Reference? parseReference(String reference) {
  final bibleParse = RegExp(
    r'^([0-9]? ?[a-zA-Z ]*)([0-9\:\-]*)(.*)$',
    caseSensitive: false,
  );
  // if multiline, just take the first line
  String ref = reference;
  if (reference.contains('\n')) {
    ref = reference.split('\n')[0];
  }
  ref = ref.replaceAll('*', '');
  final match = bibleParse.firstMatch(ref);
  if (match == null) return null;
  final book = match.group(1)?.trim();
  if (book == null) return null;
  final range = match.group(2);
  if (range == null) {
    return Reference(
      book: book,
      startChapter: null,
      startVerse: null,
      endChapter: null,
      endVerse: null,
    );
  }
  final rangeParts = range.split('-');
  if (rangeParts.length == 2) {
    final startParts = rangeParts[0].split(':');
    final endParts = rangeParts[1].split(':');

    String? startChapter, startVerse, endChapter, endVerse;

    if (startParts.length == 2) {
      startChapter = startParts[0];
      startVerse = startParts[1];
    } else {
      startChapter = startParts[0];
    }

    if (endParts.length == 2) {
      endChapter = endParts[0];
      endVerse = endParts[1];
    } else {
      if (startParts.length == 2) {
        endChapter = startChapter;
        endVerse = endParts[0];
      } else {
        endChapter = endParts[0];
      }
    }

    return Reference(
      book: book,
      startChapter: int.tryParse(startChapter),
      startVerse: startVerse != null ? int.tryParse(startVerse) : null,
      endChapter: int.tryParse(endChapter),
      endVerse: endVerse != null ? int.tryParse(endVerse) : null,
    );
  } else {
    final parts = rangeParts[0].split(':');
    String? chapter, verse;

    if (parts.length == 2) {
      chapter = parts[0];
      verse = parts[1];
    } else {
      chapter = parts[0];
    }

    return Reference(
      book: book,
      startChapter: int.tryParse(chapter),
      startVerse: verse != null ? int.tryParse(verse) : null,
      endChapter: null,
      endVerse: null,
    );
  }
}

Map<String, int> _bookOrderMap = {
  'genesis': 0, 'gen': 0, //
  'exodus': 1, 'exo': 1, 'ex': 1, //
  'leviticus': 2, 'lev': 2, //
  'numbers': 3, 'num': 3, 'nu': 3, //
  'deuteronomy': 4, 'deut': 4, 'dt': 4, //
  'joshua': 5, 'josh': 5, 'jos': 5, //
  'judges': 6, 'jdg': 6, //
  'ruth': 7, 'rut': 7, //
  '1 samuel': 8, '1 sam': 8, '1sa': 8, //
  '2 samuel': 9, '2 sam': 9, '2sa': 9, //
  '1 kings': 10, '1 kgs': 10, '1ki': 10, //
  '2 kings': 11, '2 kgs': 11, '2ki': 11, //
  '1 chronicles': 12, '1 chr': 12, '1ch': 12, //
  '2 chronicles': 13, '2 chr': 13, '2ch': 13, //
  'ezra': 14, 'ezr': 14, //
  'nehemiah': 15, 'neh': 15, //
  'esther': 16, 'esth': 16, 'est': 16, //
  'job': 17, //
  'psalms': 18, 'psalm': 18, 'ps': 18, 'psa': 18, //
  'proverbs': 19, 'prov': 19, 'pro': 19, //
  'ecclesiastes': 20, 'eccl': 20, 'ecc': 20, //
  'song of solomon': 21, 'song': 21, 'sos': 21, //
  'isaiah': 22, 'isa': 22, //
  'jeremiah': 23, 'jer': 23, //
  'lamentations': 24, 'lam': 24, //
  'ezekiel': 25, 'ezek': 25, 'eze': 25, //
  'daniel': 26, 'dan': 26, //
  'hosea': 27, 'hos': 27, //
  'joel': 28, 'joe': 28, //
  'amos': 29, 'amo': 29, //
  'obadiah': 30, 'obad': 30, 'oba': 30, //
  'jonah': 31, 'jon': 31, //
  'micah': 32, 'mic': 32, //
  'nahum': 33, 'nah': 33, //
  'habakkuk': 34, 'hab': 34, //
  'zephaniah': 35, 'zeph': 35, 'zep': 35, //
  'haggai': 36, 'hag': 36, //
  'zechariah': 37, 'zech': 37, 'zec': 37, //
  'malachi': 38, 'mal': 38, //
  'matthew': 39, 'matt': 39, 'mt': 39, 'mat': 39, //
  'mark': 40, 'mk': 40, 'mar': 40, 'mrk': 40, //
  'luke': 41, 'lk': 41, 'luk': 41, //
  'john': 42, 'jn': 42, 'joh': 42, 'jhn': 42, //
  'acts': 43, 'act': 43, //
  'romans': 44, 'rom': 44, //
  '1 corinthians': 45, '1 cor': 45, '1co': 45, //
  '2 corinthians': 46, '2 cor': 46, '2co': 46, //
  'galatians': 47, 'gal': 47, //
  'ephesians': 48, 'eph': 48, //
  'philippians': 49, 'phil': 49, 'php': 49, //
  'colossians': 50, 'col': 50, //
  '1 thessalonians': 51, '1 thess': 51, '1th': 51, //
  '2 thessalonians': 52, '2 thess': 52, '2th': 52, //
  '1 timothy': 53, '1 tim': 53, '1ti': 53, //
  '2 timothy': 54, '2 tim': 54, '2ti': 54, //
  'titus': 55, 'tit': 55, //
  'philemon': 56, 'phm': 56, //
  'hebrews': 57, 'heb': 57, //
  'james': 58, 'jam': 58, //
  '1 peter': 59, '1 pet': 59, '1pe': 59, //
  '2 peter': 60, '2 pet': 60, '2pe': 60, //
  '1 john': 61, '1 jn': 61, '1jo': 61, '1jn': 61, //
  '2 john': 62, '2 jn': 62, '2jo': 62, '2jn': 62, //
  '3 john': 63, '3 jn': 63, '3jo': 63, '3jn': 63, //
  'jude': 64, 'jde': 64, //
  'revelation': 65, 'rev': 65, //
};
