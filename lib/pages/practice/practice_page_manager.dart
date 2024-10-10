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

enum PracticeMode {
  /// Spaced repetition practice.
  reviewByDueDate,

  /// Always give a fixed number of practice verses.
  fixedReview,

  /// Casual practice is when a user practices all of the verses in a collection
  /// but the responses are not saved.
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
  final hintButtonNotifier = ValueNotifier<HintButtonState>(HintButtonState.initial());
  final canUndoNotifier = ValueNotifier<bool>(false);

  late List<Verse> _verses;
  Verse? _undoVerse;

  String? get currentVerseId {
    if (_verses.isEmpty) return null;
    return _verses.first.id;
  }

  Color _textThemeColor = Colors.black;
  set textThemeColor(Color? value) => _textThemeColor = value ?? Colors.black;

  Color _textHighlightColor = Colors.black;
  set textHighlightColor(Color? value) => _textHighlightColor = value ?? Colors.black;

  // Response button titles
  String hardTitle = '';
  String goodTitle = '';

  PracticeMode get practiceMode => _practiceMode;

  late PracticeMode _practiceMode;
  late Collection _collection;
  late List<Collection> _collections;

  Future<void> init({
    required Collection collection,
  }) async {
    uiNotifier.value = PracticeState.loading;
    _collection = collection;
    _practiceMode = (collection.studyStyle == StudyStyle.reviewByDate) //
        ? PracticeMode.reviewByDueDate
        : PracticeMode.fixedReview;
    final newVerseLimit = userSettings.getDailyLimit;
    _verses = await localStorage.fetchTodaysVerses(
      collection: collection,
      newVerseLimit: newVerseLimit,
    );
    localStorage.fetchCollections().then((value) => _collections = value);
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
    if (_practiceMode == PracticeMode.reviewByDueDate) {
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

    // good
    final goodDays = _nextIntervalInDays(verse, Difficulty.good);
    goodTitle = _formatDuration(Duration(days: goodDays));
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
    answerNotifier.value = (currentText == hint) ? const NoAnswer() : CustomHint(_addHighlighting(hint));
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
    } else {
      _handleReviewVerse(verse, response);
    }
  }

  void _handleCasualPracticeVerse(Verse verse, Difficulty response) {
    if (response == Difficulty.hard) {
      _verses.add(verse);
    }
  }

  void _handleReviewVerse(Verse verse, Difficulty response) {
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
    _verses.insert(0, verse);
    localStorage.updateVerse(_collection.id, verse);
    _undoVerse = null;
    _resetUi();
  }

  Future<void> practiceAllVerses() async {
    _verses = await localStorage.fetchAllVerses(_collection.id);
    _practiceMode = PracticeMode.casualPractice;
    _resetUi();
  }

  bool get shouldShowMoveMenuItem => _collections.length > 1;

  List<Collection> otherCollections() {
    return _collections.where((collection) => collection.id != _collection.id).toList();
  }

  void moveVerse(String toCollectionId) async {
    final verse = _verses.removeAt(0);
    _undoVerse = null;
    await localStorage.updateVerse(toCollectionId, verse);
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
