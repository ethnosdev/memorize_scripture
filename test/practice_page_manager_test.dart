import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<DataRepository>()])
@GenerateNiceMocks([MockSpec<UserSettings>()])
import 'practice_page_manager_test.mocks.dart';

final twoVerses = [
  Verse(
    id: '0',
    prompt: 'a 1',
    text: 'one two three',
  ),
  Verse(
    id: '1',
    prompt: 'a 2',
    text: 'four five six',
  ),
];

void main() {
  late MockDataRepository mockDataRepository;
  late MockUserSettings mockUserSettings;
  late PracticePageManager manager;

  setUp(() {
    // Create and configure the mocks
    mockDataRepository = MockDataRepository();
    mockUserSettings = MockUserSettings();

    // Create the object under test
    manager = PracticePageManager(
      dataRepository: mockDataRepository,
      userSettings: mockUserSettings,
    );
  });

  group('initialization:', () {
    test('init on empty collection', () async {
      await manager.init(collectionId: 'whatever');

      expect(manager.verseTextNotifier.value, const TextSpan());
      expect(manager.isShowingAnswerNotifier.value, false);
    });

    test('init with collection', () async {
      when(mockDataRepository.fetchTodaysVerses(collectionId: 'whatever'))
          .thenAnswer((_) async => twoVerses);

      await manager.init(collectionId: 'whatever');

      expect(manager.verseTextNotifier.value, const TextSpan());
      expect(manager.isShowingAnswerNotifier.value, false);
    });
  });

  group('hints:', () {
    test('showNextWordHint', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => twoVerses);
      await manager.init(collectionId: 'whatever');

      manager.showNextWordHint();

      var textBefore =
          manager.verseTextNotifier.value.children?.first as TextSpan;
      var textAfter =
          manager.verseTextNotifier.value.children?.last as TextSpan;
      expect(textBefore.text, 'one ');
      expect(textAfter.text, 'two three');

      manager.showNextWordHint();

      textBefore = manager.verseTextNotifier.value.children?.first as TextSpan;
      textAfter = manager.verseTextNotifier.value.children?.last as TextSpan;
      expect(textBefore.text, 'one two ');
      expect(textAfter.text, 'three');

      manager.showNextWordHint();

      textBefore = manager.verseTextNotifier.value.children?.first as TextSpan;
      textAfter = manager.verseTextNotifier.value.children?.last as TextSpan;
      expect(textBefore.text, 'one two three');
      expect(textAfter.text, '');
    });

    test('showFirstLettersHint', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => twoVerses);
      await manager.init(collectionId: 'whatever');

      manager.showFirstLettersHint();

      var text = manager.verseTextNotifier.value.text;
      expect(text, 'o t t');
    });
  });

  group('show button:', () {
    test('pressing show button shows verse text', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => twoVerses);
      await manager.init(collectionId: 'whatever');

      manager.show();

      final text = manager.verseTextNotifier.value.text;
      expect(text, 'one two three');
      expect(manager.isShowingAnswerNotifier.value, true);
    });
  });

  group('4-button mode:', () {
    test('Hard button inserts new verse at index 2 in list of 4', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
            Verse(id: '3', prompt: 'p3', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();
      expect(manager.promptNotifier.value, 'p0');
      expect(manager.hardTitle, 'Again');
      expect(manager.sosoTitle, '~3 min');
      expect(manager.goodTitle, '1 day');
      expect(manager.easyTitle, '2 days');

      // mark as hard, then loop through to check that it is third in line
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '2');
      expect(manager.hardTitle, 'Again');
      expect(manager.sosoTitle, '~1 min');
      expect(manager.goodTitle, '1 day');
      expect(manager.easyTitle, '2 days');
    });

    test('Hard button inserts new verse last in list of 3', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      expect(manager.promptNotifier.value, 'p0');

      // mark as hard, then loop through to check that it is last
      manager.show();
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();
      manager.onResponse(Difficulty.easy);

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '1');
    });

    test('Hard button inserts new verse last in list of 2', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      expect(manager.promptNotifier.value, 'p0');

      // mark as hard, then loop through to check that it is last
      manager.show();
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.easy);

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '1');
    });

    test('Hard button inserts review verse last in list of 4', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
                id: '0', prompt: 'p0', text: 'a', nextDueDate: DateTime.now()),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
            Verse(id: '3', prompt: 'p3', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      expect(manager.promptNotifier.value, 'p0');

      // mark as hard, then loop through to check that it is last
      manager.show();
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();
      manager.onResponse(Difficulty.easy);

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '1');
    });

    test('Soso button puts new verse last', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
            Verse(id: '3', prompt: 'p3', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();
      expect(manager.promptNotifier.value, 'p0');
      expect(manager.sosoTitle, '~3 min');
      expect(manager.isTwoButtonMode, false);

      manager.onResponse(Difficulty.soso);
      expect(manager.countNotifier.value, '4');
      verifyNever(mockDataRepository.updateVerse(any, any));

      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();
      manager.onResponse(Difficulty.easy);
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '1');
      expect(manager.sosoTitle, '0 min');
    });

    test('Soso button sets review verse one day', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
              id: '0',
              prompt: 'p0',
              text: 'a',
              nextDueDate: DateTime.now(),
              interval: const Duration(days: 3),
            ),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.sosoTitle, '1 day');
      expect(manager.isTwoButtonMode, false);

      manager.onResponse(Difficulty.soso);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;
      expect(verse.interval.inDays, 1);
      expect(manager.countNotifier.value, '1');
    });

    test('Good button sets new verse one day', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '1 day');

      manager.onResponse(Difficulty.good);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;
      expect(verse.interval.inDays, 1);
      expect(manager.countNotifier.value, '1');
    });

    test('Good button sets 0-interval review verse one day', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
                id: '0', prompt: 'p0', text: 'a', nextDueDate: DateTime.now()),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '1 day');

      manager.onResponse(Difficulty.good);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;

      expect(verse.interval.inDays, 1);
      expect(manager.countNotifier.value, '1');
    });

    test('Good button increases interval by one day', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
              id: '0',
              prompt: 'p0',
              text: 'a',
              nextDueDate: DateTime.now(),
              interval: const Duration(days: 3),
            ),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '4 days');

      manager.onResponse(Difficulty.good);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;

      expect(verse.interval.inDays, 4);
      expect(manager.countNotifier.value, '1');
    });

    test('Easy button sets new verse 2 days', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.easyTitle, '2 days');

      manager.onResponse(Difficulty.easy);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;
      expect(verse.interval.inDays, 2);
      expect(manager.countNotifier.value, '1');
    });

    test('Easy button doubles good button interval', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(false);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
              id: '0',
              prompt: 'p0',
              text: 'a',
              nextDueDate: DateTime.now(),
              interval: const Duration(days: 3),
            ),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '4 days');
      expect(manager.easyTitle, '8 days');

      manager.onResponse(Difficulty.easy);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;
      expect(verse.interval.inDays, 8);
      expect(manager.countNotifier.value, '1');
    });
  });

  group('2-button mode:', () {
    test('Hard button inserts new verse at index 2 in list of 4', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
            Verse(id: '3', prompt: 'p3', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();
      expect(manager.promptNotifier.value, 'p0');
      expect(manager.hardTitle, 'Again');
      expect(manager.goodTitle, '~3 min');

      // mark as hard, then loop through to check that it is third in line
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '4');
      expect(manager.hardTitle, 'Again');
      expect(manager.goodTitle, '~3 min');
    });

    test('Hard button inserts new verse last in list of 3', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      expect(manager.promptNotifier.value, 'p0');

      // mark as hard, then loop through to check that it is last
      manager.show();
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();
      manager.onResponse(Difficulty.good);

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '3');
    });

    test('Hard button inserts new verse last in list of 2', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      expect(manager.promptNotifier.value, 'p0');

      // mark as hard, then loop through to check that it is last
      manager.show();
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.good);

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '2');
    });

    test('Hard button inserts review verse last in list of 4', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
                id: '0', prompt: 'p0', text: 'a', nextDueDate: DateTime.now()),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
            Verse(id: '3', prompt: 'p3', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      expect(manager.promptNotifier.value, 'p0');

      // mark as hard, then loop through to check that it is last
      manager.show();
      manager.onResponse(Difficulty.hard);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();
      manager.onResponse(Difficulty.good);

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '4');
    });

    test('Good button puts new verse last', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(id: '0', prompt: 'p0', text: 'a'),
            Verse(id: '1', prompt: 'p1', text: 'a'),
            Verse(id: '2', prompt: 'p2', text: 'a'),
            Verse(id: '3', prompt: 'p3', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();
      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '~3 min');
      expect(manager.isTwoButtonMode, true);

      manager.onResponse(Difficulty.good);
      expect(manager.countNotifier.value, '4');
      verifyNever(mockDataRepository.updateVerse(any, any));

      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();
      manager.onResponse(Difficulty.good);
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.countNotifier.value, '4');
      expect(manager.goodTitle, '1 day');
    });

    test('Good button sets 0-interval review verse one day', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
                id: '0', prompt: 'p0', text: 'a', nextDueDate: DateTime.now()),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '1 day');

      manager.onResponse(Difficulty.good);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;

      expect(verse.interval.inDays, 1);
      expect(manager.countNotifier.value, '1');
    });

    test('Good button increases interval by one day', () async {
      when(mockUserSettings.getDailyLimit).thenReturn(10);
      when(mockUserSettings.isTwoButtonMode).thenReturn(true);
      when(mockDataRepository.fetchTodaysVerses(
        collectionId: 'whatever',
        newVerseLimit: 10,
      )).thenAnswer((_) async => [
            Verse(
              id: '0',
              prompt: 'p0',
              text: 'a',
              nextDueDate: DateTime.now(),
              interval: const Duration(days: 3),
            ),
            Verse(id: '1', prompt: 'p1', text: 'a'),
          ]);
      await manager.init(collectionId: 'whatever');
      manager.show();

      expect(manager.promptNotifier.value, 'p0');
      expect(manager.goodTitle, '4 days');

      manager.onResponse(Difficulty.good);
      final verse = verify(
        mockDataRepository.updateVerse(any, captureAny),
      ).captured.single as Verse;

      expect(verse.interval.inDays, 4);
      expect(manager.countNotifier.value, '1');
    });
  });
}
