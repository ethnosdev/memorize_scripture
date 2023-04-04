import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/user_settings.dart';

enum PracticeState {
  /// The wait time while querying the data repository
  loading,

  /// A user has added a new collection but hasn't added any verses to it yet
  emptyCollection,

  /// There are verses due to practice
  practicing,

  /// The verses for the day are finished
  finished,
}

class PracticePageManager {
  PracticePageManager({
    DataRepository? dataRepository,
    UserSettings? userSettings,
  }) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
    this.userSettings = userSettings ?? getIt<UserSettings>();
  }
  late final DataRepository dataRepository;
  late final UserSettings userSettings;

  final uiNotifier = ValueNotifier<PracticeState>(PracticeState.loading);
  final countNotifier = ValueNotifier<String>('');
  final promptNotifier = ValueNotifier<String>('');
  final answerNotifier = ValueNotifier<TextSpan>(const TextSpan());
  final isShowingAnswerNotifier = ValueNotifier<bool>(false);

  late List<Verse> _verses;

  String? get currentVerseId {
    if (_verses.isEmpty) return null;
    return _verses.first.id;
  }

  Color _textThemeColor = Colors.black;
  set textThemeColor(Color? value) => _textThemeColor = value ?? Colors.black;

  late String _collectionId;

  Future<void> init({
    required String collectionId,
  }) async {
    uiNotifier.value = PracticeState.loading;
    _collectionId = collectionId;
    _verses = await dataRepository.fetchAllVerses(collectionId);
    if (_verses.isEmpty) {
      uiNotifier.value = PracticeState.emptyCollection;
      return;
    }
    promptNotifier.value = _verses.first.prompt;
    countNotifier.value = _verses.length.toString();
    uiNotifier.value = PracticeState.practicing;
  }

  void show() {
    isShowingAnswerNotifier.value = true;
    answerNotifier.value = TextSpan(
      text: _verses[0].answer,
      style: TextStyle(color: _textThemeColor),
    );
  }

  int _numberHintWordsShowing = 0;

  void showNextWordHint() {
    answerNotifier.value = _formatForNumberOfWords(
      _numberHintWordsShowing,
      _verses[0].answer,
    );
    _numberHintWordsShowing++;
  }

  void showFirstLettersHint() {
    final latinChar = RegExp(r'\w');
    final result = StringBuffer();
    bool isWordStart = true;
    final text = _verses[0].answer;
    for (int i = 0; i < text.length; i++) {
      final character = text[i];
      final isWordChar = character.contains(latinChar);
      if (!isWordChar || isWordStart) {
        result.write(character);
        isWordStart = !isWordChar;
      }
    }
    answerNotifier.value = TextSpan(
      text: result.toString(),
      style: TextStyle(color: _textThemeColor),
    );
  }

  TextSpan _formatForNumberOfWords(int number, String verseText) {
    if (verseText.isEmpty) return const TextSpan(text: '');

    final parts = verseText.split(' ');
    final before = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      before.write(parts[i]);
      before.write(' ');
      if (_numberHintWordsShowing == i) {
        break;
      }
    }

    final String after;
    if (before.length >= verseText.length) {
      after = '';
    } else {
      after = verseText.substring(before.length);
    }

    final textSpan = TextSpan(children: [
      TextSpan(
        text: before.toString(),
        style: TextStyle(color: _textThemeColor),
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: Colors.transparent),
      ),
    ]);

    return textSpan;
  }

  void onResponse(Difficulty response) {
    final verse = _verses.removeAt(0);
    final updatedVerse = _adjustStats(verse, response);
    dataRepository.upsertVerse(_collectionId, updatedVerse);

    isShowingAnswerNotifier.value = false;
    answerNotifier.value = const TextSpan();
    if (response == Difficulty.hard) {
      _verses.add(updatedVerse);
    }
    if (_verses.isEmpty) {
      promptNotifier.value = '';
      uiNotifier.value = PracticeState.finished;
    } else {
      promptNotifier.value = _verses[0].prompt;
    }
    countNotifier.value = _verses.length.toString();
  }

  Verse _adjustStats(Verse verse, Difficulty difficulty) {
    // if hard, do it today
    // if ok, do it one day later than last time: x + 1
    // interval 0 days: 1 day
    // interval 1 days: 2 days
    // interval 2 days: 3 days
    // interval 3 days: 4 days
    // if easy, double the intervals: max(2(x + 1), 4)
    // interval 0: 4 days
    // interval 1: 4 days
    // interval 2: 6 days
    // interval 3: 8 days
    // example buttons
    // always pressing easy
    // Again (1 min), 1 day, 4 days
    // Again (1 min), 5 days, 10 days
    // Again (1 min), 11 days, 22 days
    // Again (1 min), 23 days, 46 days
    // Again (1 min), 47 days, 94 days
    // Again (1 min), 95 days, 6 months (190 days)
    // always pressing ok
    // Again (1 min), 1 day, 4 days
    // Again (1 min), 2 days, 4 days
    // Again (1 min), 3 days, 6 days
    // Again (1 min), 4 days, 8 days
    // Again (1 min), 5 days, 10 days
    // pressing difficult
    // Again (1 min), 1 day, 4 days
    // Again (1 min), Today (10 min), 4 days
    // Again (1 min), Today (10 min), 4 days
    // Again (1 min), 1 day, 4 days (after pressing ok)
    int days = verse.interval.inDays;
    switch (difficulty) {
      case Difficulty.hard:
        days = 0;
        break;
      case Difficulty.ok:
        days++;
        break;
      case Difficulty.easy:
        days = max(2 * (days + 1), 4);
        break;
    }
    final now = DateTime.now();
    final nextDueDate = DateTime(now.year, now.month, now.day + days);
    return verse.copyWith(
      nextDueDate: nextDueDate,
      interval: Duration(days: days),
    );
  }
}

enum Difficulty { hard, ok, easy }
