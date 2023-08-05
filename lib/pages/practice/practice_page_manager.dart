import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/practice/helpers/letters_hint.dart';
import 'package:memorize_scripture/pages/practice/helpers/words_hint.dart';
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
  WordsHintHelper? _wordsHintHelper;

  final uiNotifier = ValueNotifier<PracticeState>(PracticeState.loading);
  final countNotifier = ValueNotifier<String>('');
  final promptNotifier = ValueNotifier<String>('');
  final answerNotifier = ValueNotifier<TextSpan>(const TextSpan());
  final isShowingAnswerNotifier = ValueNotifier<bool>(false);
  final appBarNotifier = AppBarNotifier();

  late List<Verse> _verses;
  Verse? _undoVerse;

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
    appBarNotifier.update(isPracticing: true, canUndo: false);
    _wordsHintHelper = WordsHintHelper()
      ..onFinished = _showResponseButtons
      ..init(
        text: _verses.first.text,
        textColor: _textThemeColor,
        onTap: showNextWordHint,
      );
  }

  void show() {
    _showResponseButtons();
    answerNotifier.value = TextSpan(
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
    if (verse.isNew || verse.interval.inDays == 0) {
      final minutes = _verses.length - 1;
      okTitle = _formatDuration(Duration(minutes: minutes));
    } else {
      okTitle = _formatDuration(const Duration(days: 1));
    }

    // good
    if (isTwoButtonMode && verse.isNew && _verses.length > 1) {
      final minutes = _verses.length - 1;
      goodTitle = _formatDuration(Duration(minutes: minutes));
    } else {
      final goodDays = _nextIntervalInDays(verse, Difficulty.good);
      goodTitle = _formatDuration(Duration(days: goodDays));
    }

    // easy
    final easyDays = _nextIntervalInDays(verse, Difficulty.easy);
    easyTitle = _formatDuration(Duration(days: easyDays));
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    if (days == 1) return '1 day';
    if (days > 1) return '$days days';
    final minutes = duration.inMinutes;
    if (minutes == 0) return 'Now';
    if (minutes == 6) return '~5 min';
    if (minutes == 5) return '~5 min';
    if (minutes == 4) return '~5 min';
    if (minutes < 4) return '~$minutes min';
    final rounded = (minutes / 10).round() * 10;
    return '~$rounded min';
  }

  void showNextWordHint() {
    if (_wordsHintHelper == null) return;
    answerNotifier.value = _wordsHintHelper!.nextWord();
  }

  void showFirstLettersHint() {
    final helper = LettersHintHelper(
      text: _verses.first.text,
      textColor: _textThemeColor,
      onUpdate: (textSpan) {
        answerNotifier.value = textSpan;
      },
    );
    answerNotifier.value = helper.textSpan;
  }

  void onResponse(Difficulty response) {
    _updateVerses(response);
    _resetUi();
  }

  void _updateVerses(Difficulty response) {
    final verse = _verses.removeAt(0);
    _undoVerse = verse;
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
        default:
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
    if (isTwoButtonMode) {
      final updatedVerse = _adjustVerseStats(verse, response);
      dataRepository.updateVerse(_collectionId, updatedVerse);
      if (response == Difficulty.hard) {
        _verses.add(updatedVerse);
      }
    } else {
      switch (response) {
        case Difficulty.hard:
          final updatedVerse = _adjustVerseStats(verse, response);
          dataRepository.updateVerse(_collectionId, updatedVerse);
          if (_verses.length > hardNewInsertionIndex &&
              // insert last if good greater than 1
              verse.interval.inDays == 0) {
            _verses.insert(hardNewInsertionIndex, updatedVerse);
          } else {
            _verses.add(updatedVerse);
          }
        case Difficulty.ok:
          if (verse.interval.inDays == 0) {
            _verses.add(verse);
          } else {
            final updatedVerse = _adjustVerseStats(verse, response);
            dataRepository.updateVerse(_collectionId, updatedVerse);
          }
        case Difficulty.good:
        case Difficulty.easy:
          final updatedVerse = _adjustVerseStats(verse, response);
          dataRepository.updateVerse(_collectionId, updatedVerse);
      }
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
      case Difficulty.easy:
        days = 2 * (days + 1);
    }
    return days;
  }

  void _resetUi() {
    final canUndo = _undoVerse != null;
    if (_verses.isEmpty) {
      uiNotifier.value = PracticeState.finished;
      appBarNotifier.update(isPracticing: false, canUndo: canUndo);
    } else {
      uiNotifier.value = PracticeState.practicing;
      isShowingAnswerNotifier.value = false;
      answerNotifier.value = const TextSpan();
      promptNotifier.value = _verses.first.prompt;
      countNotifier.value = _verses.length.toString();
      appBarNotifier.update(isPracticing: true, canUndo: canUndo);
      _wordsHintHelper?.init(
        text: _verses.first.text,
        textColor: _textThemeColor,
        onTap: showNextWordHint,
      );
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

  void undoResponse() {
    final verse = _undoVerse;
    if (verse == null) return;
    _verses.insert(0, verse);
    dataRepository.updateVerse(_collectionId, verse);
    _undoVerse = null;
    _resetUi();
  }
}

enum Difficulty { hard, ok, good, easy }

class AppBarNotifier extends ValueNotifier<(bool, bool)> {
  AppBarNotifier() : super((false, false));

  bool get isPracticing => value.$1;
  bool get canUndo => value.$2;

  void update({required bool isPracticing, required bool canUndo}) {
    value = (isPracticing, canUndo);
  }
}
