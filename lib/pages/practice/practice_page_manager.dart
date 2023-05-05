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

  // Response button titles
  String hardTitle = '';
  String okTitle = '';
  String easyTitle = '';

  late String _collectionId;

  Future<void> init({
    required String collectionId,
  }) async {
    uiNotifier.value = PracticeState.loading;
    _collectionId = collectionId;
    _verses = await dataRepository.fetchTodaysVerses(
      collectionId: collectionId,
    );
    if (_verses.isEmpty) {
      uiNotifier.value = PracticeState.emptyCollection;
      return;
    }
    promptNotifier.value = _verses.first.prompt;
    countNotifier.value = _verses.length.toString();
    uiNotifier.value = PracticeState.practicing;
  }

  void show() {
    _showResponseButtons();
    answerNotifier.value = TextSpan(
      text: _verses[0].answer,
      style: TextStyle(color: _textThemeColor),
    );
  }

  void _showResponseButtons() {
    _setResponseButtonTitles();
    isShowingAnswerNotifier.value = true;
  }

  void _setResponseButtonTitles() {
    final verse = _verses.first;

    if (verse.isNew) {
      hardTitle = 'Again';
      okTitle = 'Today';
      easyTitle = '${_nextIntervalInDays(verse, Difficulty.easy)} days';
    } else {
      final okDays = _nextIntervalInDays(verse, Difficulty.ok);
      final s = (okDays == 1) ? '' : 's';
      hardTitle = 'Again';
      okTitle = '$okDays day$s';
      easyTitle = '${_nextIntervalInDays(verse, Difficulty.easy)} days';
    }
  }

  int _numberHintWordsShowing = 0;

  void showNextWordHint() {
    _numberHintWordsShowing++;
    answerNotifier.value = _formatForNumberOfWords(
      _numberHintWordsShowing,
      _verses[0].answer,
    );
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

    final pattern = _upToNthSpacePattern(number);
    final match = pattern.firstMatch(verseText);

    if (match == null) {
      _showResponseButtons();
    }

    final textSpan = TextSpan(children: [
      TextSpan(
        text: match?.group(1) ?? verseText,
        style: TextStyle(color: _textThemeColor),
      ),
      TextSpan(
        text: match?.group(2),
        style: const TextStyle(color: Colors.transparent),
      ),
    ]);

    return textSpan;
  }

  RegExp _upToNthSpacePattern(int n) {
    return RegExp(r'^((?:\S+\s){' + (n - 1).toString() + r'}\S+\s)(\S.*)');
  }

  void onResponse(Difficulty response) {
    _updateVerses(response);
    _resetUi();
  }

  void _updateVerses(Difficulty response) {
    final verse = _verses.removeAt(0);
    if (verse.isNew) {
      _handleNewVerse(verse, response);
    } else {
      _handleReviewVerse(verse, response);
    }
  }

  void _handleNewVerse(Verse verse, Difficulty response) {
    switch (response) {
      case Difficulty.hard:
        // The user needs to practice a new verse again soon,
        // so put it third in line (unless there aren't enough)
        if (_verses.length > 2) {
          _verses.insert(2, verse);
        } else {
          _verses.add(verse);
        }
        break;
      case Difficulty.ok:
        // Giving it a due date will make it no longer new.
        // However, we won't save it to the data repo yet.
        // Just put it at the back of today's list.
        final updated = verse.copyWith(nextDueDate: DateTime.now());
        _verses.add(updated);
        break;
      case Difficulty.easy:
        final update = _adjustStats(verse, response);
        dataRepository.updateVerse(_collectionId, update);
        break;
      default:
    }
  }

  void _handleReviewVerse(Verse verse, Difficulty response) {
    final updatedVerse = _adjustStats(verse, response);
    dataRepository.updateVerse(_collectionId, updatedVerse);
    // Keep practicing hard verses until they are ok.
    // Add the verse to the end of the list.
    if (response == Difficulty.hard) {
      _verses.add(updatedVerse);
    }
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
    // Again (1 min), 1 day, 4 days
    // Again (1 min), 1 day, 4 days
    // Again (1 min), 1 day, 4 days

    final days = _nextIntervalInDays(verse, difficulty);
    final now = DateTime.now();
    final nextDueDate = DateTime(now.year, now.month, now.day + days);
    return verse.copyWith(
      nextDueDate: nextDueDate,
      interval: Duration(days: days),
    );
  }

  int _nextIntervalInDays(Verse verse, Difficulty difficulty) {
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
    return days;
  }

  void _resetUi() {
    if (_verses.isEmpty) {
      uiNotifier.value = PracticeState.finished;
    } else {
      isShowingAnswerNotifier.value = false;
      answerNotifier.value = const TextSpan();
      promptNotifier.value = _verses.first.prompt;
      countNotifier.value = _verses.length.toString();
      _numberHintWordsShowing = 0;
    }
  }

  void onFinishedEditing(String? verseId) async {
    if (verseId == null) return;
    final verse = await dataRepository.fetchVerse(verseId: verseId);
    if (verse == null) return;
    _verses[0] = verse;
    _resetUi();
  }

  void onVerseAdded() {
    init(collectionId: _collectionId);
  }
}

enum Difficulty { hard, ok, easy }
