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

  /// The collection has verses but there are no more due today.
  noVersesDue,

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
  final verseTextNotifier = ValueNotifier<TextSpan>(const TextSpan());
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
  String goodTitle = '';
  String easyTitle = '';

  bool get isTwoButtonMode => userSettings.isTwoButtonMode;

  static const hardNewInsertionIndex = 2;

  late String _collectionId;

  Future<void> init({
    required String collectionId,
  }) async {
    uiNotifier.value = PracticeState.loading;
    _collectionId = collectionId;
    final newVerseLimit = userSettings.getDailyLimit;
    _verses = await dataRepository.fetchTodaysVerses(
      collectionId: collectionId,
      newVerseLimit: newVerseLimit,
    );
    if (_verses.isEmpty) {
      final number = await dataRepository.numberInCollection(collectionId);
      if (number > 0) {
        uiNotifier.value = PracticeState.noVersesDue;
      } else {
        uiNotifier.value = PracticeState.emptyCollection;
      }
      return;
    }
    promptNotifier.value = _verses.first.prompt;
    countNotifier.value = _verses.length.toString();
    uiNotifier.value = PracticeState.practicing;
  }

  void show() {
    _showResponseButtons();
    verseTextNotifier.value = TextSpan(
      text: _verses.first.text,
      style: TextStyle(color: _textThemeColor),
    );
  }

  void _showResponseButtons() {
    _setResponseButtonTimeSubtitles();
    isShowingAnswerNotifier.value = true;
  }

  void _setResponseButtonTimeSubtitles() {
    final verse = _verses.first;

    // hard
    hardTitle = 'Again';

    // ok
    if (verse.isNew) {
      final minutes = _verses.length - 1;
      okTitle = (minutes == 0) ? '0 min' : '~$minutes min';
    } else {
      okTitle = '1 day';
    }

    // good
    if (isTwoButtonMode && verse.isNew && _verses.length > 1) {
      final minutes = _verses.length - 1;
      goodTitle = '~$minutes min';
    } else {
      final goodDays = _nextIntervalInDays(verse, Difficulty.good);
      final s = (goodDays == 1) ? '' : 's';
      goodTitle = '$goodDays day$s';
    }

    // easy
    easyTitle = '${_nextIntervalInDays(verse, Difficulty.easy)} days';
  }

  int _numberHintWordsShowing = 0;

  void showNextWordHint() {
    _numberHintWordsShowing++;
    verseTextNotifier.value = _formatForNumberOfWords(
      _numberHintWordsShowing,
      _verses.first.text,
    );
  }

  void showFirstLettersHint() {
    final latinChar = RegExp(r'\w');
    final result = StringBuffer();
    bool isWordStart = true;
    final text = _verses.first.text;
    for (int i = 0; i < text.length; i++) {
      final character = text[i];
      final isWordChar = character.contains(latinChar);
      if (!isWordChar || isWordStart) {
        result.write(character);
        isWordStart = !isWordChar;
      }
    }
    verseTextNotifier.value = TextSpan(
      text: result.toString(),
      style: TextStyle(color: _textThemeColor),
    );
  }

  TextSpan _formatForNumberOfWords(int number, String verseText) {
    if (verseText.isEmpty) return const TextSpan(text: '');

    final index = _indexAfterNthSpace(number, verseText);
    final before = verseText.substring(0, index);
    final after = (index == null) ? '' : verseText.substring(index);

    if (index == null) {
      _showResponseButtons();
    }

    final textSpan = TextSpan(children: [
      TextSpan(
        text: before,
        style: TextStyle(color: _textThemeColor),
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: Colors.transparent),
      ),
    ]);

    return textSpan;
  }

  /// number is 1-based
  int? _indexAfterNthSpace(int number, String verseText) {
    int index = 0;
    for (int i = 1; i <= number; i++) {
      var temp = _advanceToNextWhiteSpace(index, verseText);
      if (temp == null) return null;
      index = temp;
      temp = _advanceToNextNonWhiteSpace(index, verseText);
      if (temp == null) return null;
      index = temp;
    }
    return index;
  }

  int? _advanceToNextNonWhiteSpace(int start, String text) {
    final nonWhiteSpace = RegExp(r'\S');
    final index = text.indexOf(nonWhiteSpace, start);
    return (index < 0) ? null : index;
  }

  int? _advanceToNextWhiteSpace(int start, String text) {
    final whiteSpace = RegExp(r'\s');
    final index = text.indexOf(whiteSpace, start);
    return (index < 0) ? null : index;
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
    if (isTwoButtonMode) {
      switch (response) {
        case Difficulty.hard:
          // The user needs to practice a new verse again soon,
          // so put it third in line (unless there aren't enough)
          if (_verses.length > hardNewInsertionIndex) {
            _verses.insert(hardNewInsertionIndex, verse);
          } else {
            _verses.add(verse);
          }
        case Difficulty.ok:
          throw 'Illegal state: This is two-button mode.';
        case Difficulty.good:
          if (_verses.isEmpty) {
            // If this is the only verse, we're finished.
            final updated = _adjustVerseStats(verse, response);
            dataRepository.updateVerse(_collectionId, updated);
          } else {
            // Giving it a due date will make it no longer new.
            // However, we won't save it to the data repo yet.
            // Just put it at the back of today's list.
            final updated = verse.copyWith(nextDueDate: DateTime.now());
            _verses.add(updated);
          }
        case Difficulty.easy:
          throw 'Illegal state: This is two-button mode.';
      }
    } else {
      // 4-button mode
      switch (response) {
        case Difficulty.hard:
          // The user needs to practice a new verse again soon,
          // so put it third in line (unless there aren't enough)
          if (_verses.length > hardNewInsertionIndex) {
            _verses.insert(hardNewInsertionIndex, verse);
          } else {
            _verses.add(verse);
          }
        case Difficulty.ok:
          _verses.add(verse);
        case Difficulty.good:
        case Difficulty.easy:
          final update = _adjustVerseStats(verse, response);
          dataRepository.updateVerse(_collectionId, update);
      }
    }
  }

  void _handleReviewVerse(Verse verse, Difficulty response) {
    final updatedVerse = _adjustVerseStats(verse, response);
    dataRepository.updateVerse(_collectionId, updatedVerse);
    // Put hard verses at the end of the list
    if (response == Difficulty.hard) {
      _verses.add(updatedVerse);
    }
  }

  Verse _adjustVerseStats(Verse verse, Difficulty difficulty) {
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
      case Difficulty.ok:
        days = 1;
      case Difficulty.good:
        days++;
        break;
      case Difficulty.easy:
        days = 2 * (days + 1);
        break;
    }
    return days;
  }

  void _resetUi() {
    if (_verses.isEmpty) {
      uiNotifier.value = PracticeState.finished;
    } else {
      isShowingAnswerNotifier.value = false;
      verseTextNotifier.value = const TextSpan();
      promptNotifier.value = _verses.first.prompt;
      countNotifier.value = _verses.length.toString();
      _numberHintWordsShowing = 0;
    }
  }

  void onFinishedAddingEditing(String? verseId) async {
    final isAdding = verseId == null;
    if (isAdding) {
      init(collectionId: _collectionId);
      return;
    }
    final verse = await dataRepository.fetchVerse(verseId: verseId);
    if (verse == null) return;
    _verses[0] = verse;
    _resetUi();
  }
}

enum Difficulty { hard, ok, good, easy }
