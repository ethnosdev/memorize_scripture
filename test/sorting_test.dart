import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/common/sorting.dart';

void main() {
  group('Parse reference:', () {
    test('standard', () {
      const input = 'John 3:16';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 16);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('book with number', () {
      const input = '1 John 3:16';
      final reference = parseReference(input);
      expect(reference!.book, '1 John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 16);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('book with spaces', () {
      const input = 'Song of Solomon 3:16';
      final reference = parseReference(input);
      expect(reference!.book, 'Song of Solomon');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 16);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('no verse', () {
      const input = 'John 3';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, null);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('no chapter', () {
      const input = 'John';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, null);
      expect(reference.startVerse, null);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('no chapter in book with number', () {
      const input = '1 John';
      final reference = parseReference(input);
      expect(reference!.book, '1 John');
      expect(reference.startChapter, null);
      expect(reference.startVerse, null);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('no chapter in book with spaces', () {
      const input = 'Song of Solomon';
      final reference = parseReference(input);
      expect(reference!.book, 'Song of Solomon');
      expect(reference.startChapter, null);
      expect(reference.startVerse, null);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('not a reference', () {
      const input = 'random text';
      final reference = parseReference(input);
      expect(reference!.book, 'random text');
      expect(reference.startChapter, null);
      expect(reference.startVerse, null);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });

    test('verse range', () {
      const input = 'John 3:16-18';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 16);
      expect(reference.endChapter, 3);
      expect(reference.endVerse, 18);
    });

    test('chapter range', () {
      const input = 'John 3-4';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, null);
      expect(reference.endChapter, 4);
      expect(reference.endVerse, null);
    });

    test('chapter verse range', () {
      const input = 'John 3:1-4:3';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 1);
      expect(reference.endChapter, 4);
      expect(reference.endVerse, 3);
    });

    test('numbered book verse range', () {
      const input = '1 John 3:16-18';
      final reference = parseReference(input);
      expect(reference!.book, '1 John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 16);
      expect(reference.endChapter, 3);
      expect(reference.endVerse, 18);
    });

    test('numbered book chapter range', () {
      const input = '1 John 3-4';
      final reference = parseReference(input);
      expect(reference!.book, '1 John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, null);
      expect(reference.endChapter, 4);
      expect(reference.endVerse, null);
    });

    test('numbered book chapter verse range', () {
      const input = '1 John 3:1-4:3';
      final reference = parseReference(input);
      expect(reference!.book, '1 John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 1);
      expect(reference.endChapter, 4);
      expect(reference.endVerse, 3);
    });

    test('spaced book verse range', () {
      const input = 'Song of Solomon 3:16-18';
      final reference = parseReference(input);
      expect(reference!.book, 'Song of Solomon');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 16);
      expect(reference.endChapter, 3);
      expect(reference.endVerse, 18);
    });

    test('spaced book chapter range', () {
      const input = 'Song of Solomon 3-4';
      final reference = parseReference(input);
      expect(reference!.book, 'Song of Solomon');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, null);
      expect(reference.endChapter, 4);
      expect(reference.endVerse, null);
    });

    test('spaced book chapter verse range', () {
      const input = 'Song of Solomon 3:1-4:3';
      final reference = parseReference(input);
      expect(reference!.book, 'Song of Solomon');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 1);
      expect(reference.endChapter, 4);
      expect(reference.endVerse, 3);
    });

    test('reference with extra', () {
      const input = 'John 3:1 (NIV)';
      final reference = parseReference(input);
      expect(reference!.book, 'John');
      expect(reference.startChapter, 3);
      expect(reference.startVerse, 1);
      expect(reference.endChapter, null);
      expect(reference.endVerse, null);
    });
  });

  group('Sort biblically:', () {
    test('book only reference', () {
      final examples = ['John', 'Matthew'];
      final sorted = sortBiblically(examples);
      expect(sorted.first, 'Matthew');
      expect(sorted.last, 'John');
    });

    test('book and chapter', () {
      final examples = ['John 10', 'John 1'];
      final sorted = sortBiblically(examples);
      expect(sorted.first, 'John 1');
      expect(sorted.last, 'John 10');
    });

    test('book chapter and verse', () {
      final examples = ['John 1:10', 'John 1:1'];
      final sorted = sortBiblically(examples);
      expect(sorted.first, 'John 1:1');
      expect(sorted.last, 'John 1:10');
    });

    test('reference with extra', () {
      final examples = ['John 1:10 (NIV)', 'John 1:1 (NIV)'];
      final sorted = sortBiblically(examples);
      expect(sorted.first, 'John 1:1 (NIV)');
      expect(sorted.last, 'John 1:10 (NIV)');
    });
  });
}
