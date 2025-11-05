import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/sorting.dart';
import 'package:memorize_scripture/common/verse.dart';

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

  group('Sort verses biblically:', () {
    test('book only reference', () {
      final john = Verse(id: 'a', prompt: 'John', text: '');
      final matt = Verse(id: 'b', prompt: 'Matthew', text: '');
      final examples = [john, matt];
      sortVersesBiblically(examples);
      expect(examples.first, matt);
      expect(examples.last, john);
    });

    test('book and chapter', () {
      final john10 = Verse(id: 'a', prompt: 'John 10', text: '');
      final john1 = Verse(id: 'b', prompt: 'John 1', text: '');
      final examples = [john10, john1];
      sortVersesBiblically(examples);
      expect(examples.first, john1);
      expect(examples.last, john10);
    });

    test('book chapter and verse', () {
      final john110 = Verse(id: 'a', prompt: 'John 1:10', text: '');
      final john11 = Verse(id: 'b', prompt: 'John 1:1', text: '');
      final examples = [john110, john11];
      sortVersesBiblically(examples);
      expect(examples.first, john11);
      expect(examples.last, john110);
    });

    test('reference with extra', () {
      final john110 = Verse(id: 'a', prompt: 'John 1:10 (NIV)', text: '');
      final john11 = Verse(id: 'b', prompt: 'John 1:1 (NIV)', text: '');
      final examples = [john110, john11];
      sortVersesBiblically(examples);
      expect(examples.first, john11);
      expect(examples.last, john110);
    });

    test('sort alphabetically for same reference', () {
      final b = Verse(id: 'b', prompt: 'John 1:10 (NIV)\nbbb', text: '');
      final a = Verse(id: 'a', prompt: 'John 1:10 (NIV)\naaa', text: '');
      final examples = [b, a];
      sortVersesBiblically(examples);
      expect(examples.first.id, 'a');
      expect(examples.last.id, 'b');
    });
  });

  group('Sort collections biblically:', () {
    test('book only reference', () {
      final john = Collection(
          id: 'a',
          name: 'John',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final matt = Collection(
          id: 'b',
          name: 'Matthew',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final examples = [john, matt];
      sortCollectionsBiblically(examples);
      expect(examples.first, matt);
      expect(examples.last, john);
    });

    test('book and chapter', () {
      final john10 = Collection(
          id: 'a',
          name: 'John 10',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final john1 = Collection(
          id: 'b',
          name: 'John 1',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final examples = [john10, john1];
      sortCollectionsBiblically(examples);
      expect(examples.first, john1);
      expect(examples.last, john10);
    });

    test('book chapter and verse', () {
      final john110 = Collection(
          id: 'a',
          name: 'John 1:10',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final john11 = Collection(
          id: 'b',
          name: 'John 1:1',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final examples = [john110, john11];
      sortCollectionsBiblically(examples);
      expect(examples.first, john11);
      expect(examples.last, john110);
    });

    test('reference with extra', () {
      final john110 = Collection(
          id: 'a',
          name: 'John 1:10 (NIV)',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final john11 = Collection(
          id: 'b',
          name: 'John 1:1 (NIV)',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final examples = [john110, john11];
      sortCollectionsBiblically(examples);
      expect(examples.first, john11);
      expect(examples.last, john110);
    });

    test('sort alphabetically for same reference', () {
      final b = Collection(
          id: 'b',
          name: 'John 1:10 (NIV)\nbbb',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final a = Collection(
          id: 'a',
          name: 'John 1:10 (NIV)\naaa',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final examples = [b, a];
      sortCollectionsBiblically(examples);
      expect(examples.first.id, 'a');
      expect(examples.last.id, 'b');
    });

    test('sort pinned first', () {
      final b = Collection(
          isPinned: false,
          id: 'b',
          name: 'Matthew',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final a = Collection(
          isPinned: true,
          id: 'a',
          name: 'John',
          studyStyle: StudyStyle.fixedDays,
          createdDate: DateTime(2024));
      final examples = [b, a];
      sortCollectionsBiblically(examples);
      expect(examples.first.id, 'a');
      expect(examples.last.id, 'b');
    });
  });
}
