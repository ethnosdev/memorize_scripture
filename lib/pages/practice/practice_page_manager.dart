import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class PracticePageManager {
  final answerNotifier = ValueNotifier<TextSpan>(const TextSpan());
  final isShownNotifier = ValueNotifier<bool>(false);

  final dataRepo = getIt<DataRepository>();
  String _verseText = '';

  Future<void> init() async {
    _verseText = await dataRepo.fetchVerse();
  }

  void show() {
    isShownNotifier.value = true;
    answerNotifier.value = TextSpan(
      text: _verseText,
      style: const TextStyle(color: Colors.black),
    );
  }

  int _numberHintWordsShowing = 0;

  void showNextWordHint() {
    answerNotifier.value = _formatForNumberOfWords(
      _numberHintWordsShowing,
      _verseText,
    );
    _numberHintWordsShowing++;
  }

  void showFirstLettersHint() {
    final latinChar = RegExp(r'\w');
    final result = StringBuffer();
    bool isWordStart = true;
    for (int i = 0; i < _verseText.length; i++) {
      final character = _verseText[i];
      final isWordChar = character.contains(latinChar);
      if (!isWordChar || isWordStart) {
        result.write(character);
        isWordStart = !isWordChar;
      }
    }
    answerNotifier.value = TextSpan(
      text: result.toString(),
      style: const TextStyle(color: Colors.black),
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
        style: const TextStyle(color: Colors.black),
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: Colors.transparent),
      ),
    ]);

    return textSpan;
  }
}

// enum Display {
//   initial,
//   showingAnswer,
// }
