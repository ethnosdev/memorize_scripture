import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/highlighting.dart';
import 'package:memorize_scripture/common/sorting.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/pages/practice/helpers/letters_hint.dart';
import 'package:memorize_scripture/pages/practice/helpers/words_hint.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/user_settings.dart';

import 'helpers/language_utils.dart';

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

enum PracticeMode {
  /// Spaced repetition practice.
  reviewBySpacedRepetition,

  /// User chooses the number of days later to review a verse.
  reviewByFixedDays,

  /// Always give a fixed number of practice verses.
  reviewSameNumberPerDay,

  /// Casual practice is when a user practices all of the verses in a collection
  /// but the responses are not saved.
  casualPractice,
}

class HintButtonState {
  final bool isEnabled;
  final bool hasCustomHint;
  final bool showLettersButton;

  HintButtonState({
    required this.isEnabled,
    required this.hasCustomHint,
    required this.showLettersButton,
  });

  HintButtonState.initial()
      : this(isEnabled: true, hasCustomHint: false, showLettersButton: true);
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
  final goodTitleNotifier = ValueNotifier<String>('');
  final easyTitleNotifier = ValueNotifier<String>('');

  late List<Verse> _verses;
  Verse? _undoVerse;

  String? get currentVerseId {
    if (_verses.isEmpty) return null;
    return _verses.first.id;
  }

  Color _textThemeColor = Colors.black;
  set textThemeColor(Color? value) => _textThemeColor = value ?? Colors.black;

  Color _textHighlightColor = Colors.black;
  set textHighlightColor(Color? value) =>
      _textHighlightColor = value ?? Colors.black;

  // Response button titles
  String hardTitle = '';
  String okTitle = '';
  String get goodTitle => goodTitleNotifier.value;

  PracticeMode get practiceMode => _practiceMode;

  late PracticeMode _practiceMode;
  late Collection _collection;
  late List<Collection> _collections;

  Future<void> init({
    required Collection collection,
  }) async {
    uiNotifier.value = PracticeState.loading;
    _collection = collection;
    _practiceMode = switch (collection.studyStyle) {
      StudyStyle.spacedRepetition => PracticeMode.reviewBySpacedRepetition,
      StudyStyle.fixedDays => PracticeMode.reviewByFixedDays,
      StudyStyle.sameNumberPerDay => PracticeMode.reviewSameNumberPerDay,
    };
    final newVerseLimit = userSettings.getDailyLimit;
    _verses = await localStorage.fetchTodaysVerses(
      collection: collection,
      newVerseLimit: newVerseLimit,
    );
    if (userSettings.isBiblicalOrder) {
      sortVersesBiblically(_verses);
    }
    localStorage.fetchCollections().then((value) {
      _collections = value;
      if (userSettings.isBiblicalOrder) {
        sortCollectionsBiblically(_collections);
      }
    });
    if (_verses.isEmpty) {
      final number = await localStorage.numberInCollection(collection.id);
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
      return;
    }

    uiNotifier.value = PracticeState.practicing;
    isShowingAnswerNotifier.value = false;
    _updateHintButtonState(isEnabled: true);
    answerNotifier.value = const NoAnswer();
    promptNotifier.value =
        addHighlighting(_verses.first.prompt, _textHighlightColor);
    countNotifier.value = _verses.length.toString();
    _wordsHintHelper.init(
      text: _verses.first.text,
      textColor: _textThemeColor,
    );
  }

  void _updateHintButtonState({required bool isEnabled}) {
    final verse = _verses.first;

    hintButtonNotifier.value = HintButtonState(
      isEnabled: isEnabled,
      hasCustomHint: verse.hint.isNotEmpty,
      showLettersButton: !_currentVerseIsCjk,
    );
  }

  bool get _currentVerseIsCjk {
    if (_verses.isEmpty) return false;
    return isCjk(_verses.first.text);
  }

  void show() {
    _showResponseButtons();
    _showFinalAnswer();
  }

  void _showFinalAnswer() {
    final text = addHighlighting(_verses.first.text, _textHighlightColor);
    answerNotifier.value = FinalAnswer(text);
  }

  void _showResponseButtons() {
    if (_practiceMode == PracticeMode.reviewBySpacedRepetition) {
      _setSpacedRepetitionSubtitles();
    } else if (_practiceMode == PracticeMode.reviewByFixedDays) {
      _setFixedDayButtonsSubtitles();
    }
    isShowingAnswerNotifier.value = true;
    _updateHintButtonState(isEnabled: false);
  }

  void _setSpacedRepetitionSubtitles() {
    final verse = _verses.first;

    // hard
    hardTitle = 'Again';

    // good
    final goodDays = _nextIntervalInDays(verse, Difficulty.good);
    goodTitleNotifier.value = _formatDuration(Duration(days: goodDays));
  }

  void _setFixedDayButtonsSubtitles() {
    final verse = _verses.first;

    // hard
    hardTitle = 'Again';

    // ok
    final okDays = _nextIntervalInDays(verse, Difficulty.ok);
    okTitle = _formatDuration(Duration(days: okDays));

    // good
    final goodDays = _nextIntervalInDays(verse, Difficulty.good);
    goodTitleNotifier.value = _formatDuration(Duration(days: goodDays));

    // easy
    final easyDays = _nextIntervalInDays(verse, Difficulty.easy);
    easyTitleNotifier.value = _formatDuration(Duration(days: easyDays));
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
    switch (answerNotifier.value) {
      case NoAnswer():
      case LettersHint():
      case WordsHint():
      case FinalAnswer():
        final hint = _verses.first.hint;
        answerNotifier.value =
            CustomHint(addHighlighting(hint, _textHighlightColor));
      case CustomHint():
        if (isShowingAnswerNotifier.value) {
          _showFinalAnswer();
        } else {
          answerNotifier.value = const NoAnswer();
        }
    }
  }

  void onResponse(Difficulty response) {
    _updateVerses(response);
    _resetUi();
  }

  void _updateVerses(Difficulty response) {
    final verse = _verses.removeAt(0);
    _undoVerse = verse;
    if (_practiceMode == PracticeMode.casualPractice) {
      _handleCasualPracticeVerse(verse, response);
      // } else if (_practiceMode == PracticeMode.reviewSameNumberPerDay) {
      //   _handleSameNumberPerDayVerse(verse, response);
    } else {
      _handleVerse(verse, response);
    }
  }

  void _handleCasualPracticeVerse(Verse verse, Difficulty response) {
    if (response == Difficulty.hard) {
      _verses.add(verse);
    }
  }

  void _handleVerse(Verse verse, Difficulty response) {
    final updatedVerse = _adjustVerseStats(verse, response);
    localStorage.updateVerse(_collection.id, updatedVerse);
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
    switch (_practiceMode) {
      case PracticeMode.reviewBySpacedRepetition:
      case PracticeMode.reviewSameNumberPerDay:
        return _nextIntervalForSpacedRepetition(verse, difficulty);
      case PracticeMode.reviewByFixedDays:
        return _nextIntervalForFixedDays(verse, difficulty);
      case PracticeMode.casualPractice:
        throw UnimplementedError();
    }
  }

  int _nextIntervalForSpacedRepetition(Verse verse, Difficulty difficulty) {
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

  int _nextIntervalForFixedDays(Verse verse, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.hard:
        return 0;
      case Difficulty.ok:
        return 1;
      case Difficulty.good:
        return userSettings.getFixedGoodDays;
      case Difficulty.easy:
        return userSettings.getFixedEasyDays;
    }
  }

  String get fixedGoodDays => userSettings.getFixedGoodDays.toString();

  String validateFixedGoodDays(String value) {
    int result = int.tryParse(value) ?? UserSettings.defaultFixedGoodDays;
    if (result <= 1) return UserSettings.defaultFixedGoodDays.toString();
    return result.toString();
  }

  Future<void> updateFixedGoodDays(String number) async {
    final days = int.tryParse(number);
    if (days == null) return;
    await userSettings.setFixedGoodDays(days);
    goodTitleNotifier.value = _formatDuration(Duration(days: days));
  }

  String get fixedEasyDays => userSettings.getFixedEasyDays.toString();

  String validateFixedEasyDays(String value) {
    int result = int.tryParse(value) ?? UserSettings.defaultFixedEasyDays;
    if (result <= 1) return UserSettings.defaultFixedEasyDays.toString();
    return result.toString();
  }

  Future<void> updateFixedEasyDays(String number) async {
    final days = int.tryParse(number);
    if (days == null) return;
    await userSettings.setFixedEasyDays(days);
    easyTitleNotifier.value = _formatDuration(Duration(days: days));
  }

  Future<void> onFinishedAddingEditing(String? verseId) async {
    final isAdding = verseId == null;
    if (isAdding) {
      init(collection: _collection);
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
    if (_verses.isNotEmpty && _verses.last.id == verse.id) {
      _verses.removeLast();
    }
    _verses.insert(0, verse);
    localStorage.updateVerse(_collection.id, verse);
    _undoVerse = null;
    _resetUi();
  }

  Future<void> practiceAllVerses() async {
    _verses = await localStorage.fetchAllVersesInCollection(_collection.id);
    if (userSettings.isBiblicalOrder) {
      sortVersesBiblically(_verses);
    }
    _practiceMode = PracticeMode.casualPractice;
    _resetUi();
  }

  bool get shouldShowMoveMenuItem => _collections.length > 1;

  List<Collection> otherCollections() {
    return _collections
        .where((collection) => collection.id != _collection.id)
        .toList();
  }

  void moveVerse(String toCollectionId) async {
    final verse = _verses.removeAt(0);
    _undoVerse = null;
    await localStorage.updateVerse(toCollectionId, verse);
    _resetUi();
  }

  void shuffleVerses() {
    _verses.shuffle();
    _undoVerse = null;
    _resetUi();
  }
}

enum Difficulty { hard, ok, good, easy }

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
