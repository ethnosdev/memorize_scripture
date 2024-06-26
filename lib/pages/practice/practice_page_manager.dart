import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/practice/helpers/letters_hint.dart';
import 'package:memorize_scripture/pages/practice/helpers/words_hint.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
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

enum ResponseButtonMode {
  two,
  four,
  casualPractice,
}

class HintButtonState {
  final bool isEnabled;
  final bool hasCustomHint;

  HintButtonState({required this.isEnabled, required this.hasCustomHint});

  HintButtonState.initial() : this(isEnabled: true, hasCustomHint: false);
}

class PracticePageManager {
  PracticePageManager({
    LocalStorage? localStorage,
    UserSettings? userSettings,
  }) {
    this.localStorage = localStorage ?? getIt<LocalStorage>();
    this.userSettings = userSettings ?? getIt<UserSettings>();
  }
  late final LocalStorage localStorage;
  late final UserSettings userSettings;
  final _wordsHintHelper = WordsHintHelper();

  final uiNotifier = ValueNotifier<PracticeState>(PracticeState.loading);
  final countNotifier = ValueNotifier<String>('');
  final promptNotifier = ValueNotifier<TextSpan>(const TextSpan());
  final answerNotifier = ValueNotifier<AnswerType>(const NoAnswer());
  final isShowingAnswerNotifier = ValueNotifier<bool>(false);
  final hintButtonNotifier =
      ValueNotifier<HintButtonState>(HintButtonState.initial());
  final canUndoNotifier = ValueNotifier<bool>(false);

  late List<Verse> _verses;
  Verse? _undoVerse;

  // Casual practice is when a user practices all of the verses in a collection
  // but the responses are not saved.
  var _isCasualPracticeMode = false;

  String? get currentVerseId {
    if (_verses.isEmpty) return null;
    return _verses.first.id;
  }

  bool get shouldShowEasyButton {
    return _verses.first.interval.inDays < userSettings.getMaxInterval - 1;
  }

  Color _textThemeColor = Colors.black;
  set textThemeColor(Color? value) => _textThemeColor = value ?? Colors.black;

  Color _textHighlightColor = Colors.black;
  set textHighlightColor(Color? value) =>
      _textHighlightColor = value ?? Colors.black;

  // Response button titles
  String hardTitle = '';
  String okTitle = '';
  String goodTitle = '';
  String easyTitle = '';

  ResponseButtonMode get buttonMode {
    if (_isCasualPracticeMode) return ResponseButtonMode.casualPractice;
    if (userSettings.isTwoButtonMode) return ResponseButtonMode.two;
    return ResponseButtonMode.four;
  }

  static const hardNewInsertionIndex = 2;

  late String _collectionId;
  late List<Collection> _collections;

  Future<void> init({
    required String collectionId,
  }) async {
    uiNotifier.value = PracticeState.loading;
    _collectionId = collectionId;
    _isCasualPracticeMode = false;
    final newVerseLimit = userSettings.getDailyLimit;
    _verses = await localStorage.fetchTodaysVerses(
      collectionId: collectionId,
      newVerseLimit: newVerseLimit,
    );
    localStorage.fetchCollections().then((value) => _collections = value);
    if (_verses.isEmpty) {
      final number = await localStorage.numberInCollection(collectionId);
      if (number > 0) {
        uiNotifier.value = PracticeState.noVersesDue;
      } else {
        uiNotifier.value = PracticeState.emptyCollection;
      }
      return;
    }
    _resetUi();
  }

  void _resetUi() {
    canUndoNotifier.value = _undoVerse != null;
    if (_verses.isEmpty) {
      uiNotifier.value = PracticeState.finished;
    } else {
      uiNotifier.value = PracticeState.practicing;
      isShowingAnswerNotifier.value = false;
      hintButtonNotifier.value = HintButtonState(
        isEnabled: true,
        hasCustomHint: _verses.first.hint.isNotEmpty,
      );
      answerNotifier.value = const NoAnswer();
      promptNotifier.value = _addHighlighting(_verses.first.prompt);
      countNotifier.value = _verses.length.toString();
      _wordsHintHelper.init(
        text: _verses.first.text,
        textColor: _textThemeColor,
      );
    }
  }

  // Text surrounded by double asterisks should be highlighted.
  TextSpan _addHighlighting(String text) {
    final spans = <TextSpan>[];
    final regExp = RegExp(r'\*\*(.*?)\*\*', dotAll: true);
    int lastEnd = 0;
    final highlightStyle = TextStyle(
      color: _textHighlightColor,
      fontWeight: FontWeight.bold,
    );

    // Find all matches and create TextSpans
    regExp.allMatches(text).forEach((match) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
      ));
      spans.add(TextSpan(
        text: match.group(1),
        style: highlightStyle,
      ));
      lastEnd = match.end;
    });

    // Add the remaining text if any
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, text.length),
      ));
    }

    return TextSpan(children: spans);
  }

  void show() {
    _showResponseButtons();
    final text = _addHighlighting(_verses.first.text);
    answerNotifier.value = FinalAnswer(text);
  }

  void _showResponseButtons() {
    if (!_isCasualPracticeMode) {
      _setResponseButtonTimeSubtitles();
    }
    isShowingAnswerNotifier.value = true;
    hintButtonNotifier.value = HintButtonState(
      isEnabled: false,
      hasCustomHint: _verses.first.hint.isNotEmpty,
    );
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
    final isTwoButtonMode = buttonMode == ResponseButtonMode.two;
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

  void showFirstLettersHint() {
    final helper = LettersHintHelper(
      text: _verses.first.text,
      textColor: _textThemeColor,
      onUpdate: (textSpan) {
        answerNotifier.value = LettersHint(textSpan);
      },
    );
    answerNotifier.value = LettersHint(helper.textSpan);
  }

  void showNextWordHint() {
    try {
      final text = _wordsHintHelper.nextWord();
      answerNotifier.value = WordsHint(text);
    } on OnFinishedException {
      show();
    }
  }

  void showCustomHint() {
    final hint = _verses.first.hint;
    final currentText = answerNotifier.value.textSpan.text;
    answerNotifier.value = (currentText == hint)
        ? const NoAnswer()
        : CustomHint(_addHighlighting(hint));
  }

  void onResponse(Difficulty response) {
    _updateVerses(response);
    _resetUi();
  }

  void _updateVerses(Difficulty response) {
    final verse = _verses.removeAt(0);
    _undoVerse = verse;
    if (_isCasualPracticeMode) {
      _handleCasualPracticeVerse(verse, response);
    } else if (verse.isNew) {
      _handleNewVerse(verse, response);
    } else {
      _handleReviewVerse(verse, response);
    }
  }

  void _handleCasualPracticeVerse(Verse verse, Difficulty response) {
    if (response == Difficulty.hard) {
      _verses.add(verse);
    }
  }

  void _handleNewVerse(Verse verse, Difficulty response) {
    final isTwoButtonMode = buttonMode == ResponseButtonMode.two;
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
            localStorage.updateVerse(_collectionId, updated);
          } else {
            // Giving it a due date will make it no longer new.
            final updated = verse.copyWith(nextDueDate: DateTime.now());
            localStorage.updateVerse(_collectionId, updated);
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
          localStorage.updateVerse(_collectionId, update);
      }
    }
  }

  void _handleReviewVerse(Verse verse, Difficulty response) {
    final isTwoButtonMode = buttonMode == ResponseButtonMode.two;
    if (isTwoButtonMode) {
      final updatedVerse = _adjustVerseStats(verse, response);
      localStorage.updateVerse(_collectionId, updatedVerse);
      if (response == Difficulty.hard) {
        _verses.add(updatedVerse);
      }
    } else {
      switch (response) {
        case Difficulty.hard:
          final updatedVerse = _adjustVerseStats(verse, response);
          localStorage.updateVerse(_collectionId, updatedVerse);
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
            localStorage.updateVerse(_collectionId, updatedVerse);
          }
        case Difficulty.good:
        case Difficulty.easy:
          final updatedVerse = _adjustVerseStats(verse, response);
          localStorage.updateVerse(_collectionId, updatedVerse);
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
    return math.min(days, userSettings.getMaxInterval);
  }

  Future<void> onFinishedAddingEditing(String? verseId) async {
    final isAdding = verseId == null;
    if (isAdding) {
      init(collectionId: _collectionId);
      return;
    }
    final verse = await localStorage.fetchVerse(verseId: verseId);
    if (verse == null) return;
    _verses[0] = verse;
    _resetUi();
  }

  void undoResponse() {
    final verse = _undoVerse;
    if (verse == null) return;
    _verses.insert(0, verse);
    localStorage.updateVerse(_collectionId, verse);
    _undoVerse = null;
    _resetUi();
  }

  Future<void> practiceAllVerses() async {
    _verses = await localStorage.fetchAllVerses(_collectionId);
    _isCasualPracticeMode = true;
    _resetUi();
  }

  bool get shouldShowMoveMenuItem => _collections.length > 1;

  List<Collection> otherCollections() {
    return _collections
        .where((collection) => collection.id != _collectionId)
        .toList();
  }

  void moveVerse(String toCollectionId) async {
    final verse = _verses.removeAt(0);
    _undoVerse = null;
    await localStorage.updateVerse(toCollectionId, verse);
    _resetUi();
  }
}

enum Difficulty { hard, ok, good, easy }

class AppBarNotifier extends ValueNotifier<(bool, bool)> {
  AppBarNotifier() : super((false, false));

  bool get isPracticing => value.$1;
  bool get canUndo => value.$2;

  void updatek({required bool isPracticing, required bool canUndo}) {
    value = (isPracticing, canUndo);
  }
}

sealed class AnswerType {
  const AnswerType(this.textSpan);
  final TextSpan textSpan;
}

class NoAnswer extends AnswerType {
  const NoAnswer() : super(const TextSpan());
}

class LettersHint extends AnswerType {
  const LettersHint(super.textSpan);
}

class WordsHint extends AnswerType {
  const WordsHint(super.textSpan);
}

class CustomHint extends AnswerType {
  const CustomHint(super.textSpan);
}

class FinalAnswer extends AnswerType {
  const FinalAnswer(super.textSpan);
}
