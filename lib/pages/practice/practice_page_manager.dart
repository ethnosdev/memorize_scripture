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

  Future<void> init({
    required String collectionId,
  }) async {
    uiNotifier.value = PracticeState.loading;
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
    isShowingAnswerNotifier.value = false;
    answerNotifier.value = const TextSpan();
    final verse = _verses.removeAt(0);
    if (response == Difficulty.hard) {
      _verses.add(verse);
    }
    if (_verses.isEmpty) {
      promptNotifier.value = '';
      uiNotifier.value = PracticeState.finished;
    } else {
      promptNotifier.value = _verses[0].prompt;
    }
    countNotifier.value = _verses.length.toString();
  }
}

enum Difficulty { hard, ok, easy }
