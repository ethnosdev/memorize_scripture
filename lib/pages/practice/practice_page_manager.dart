import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class PracticePageManager {
  final answerNotifier = ValueNotifier<TextSpan>(const TextSpan());
  final displayNotifier = ValueNotifier<Display>(Display.initial);

  final dataRepo = getIt<DataRepository>();
  String _verseText = '';

  Future<void> init() async {
    _verseText = await dataRepo.fetchVerse();
  }

  void show() {
    displayNotifier.value = Display.showingAnswer;
  }

  int _numberHintWordsShowing = 0;

  void showNextWordHint() {
    answerNotifier.value = _formatForNumberOfWords(
      _numberHintWordsShowing,
      _verseText,
    );
    _numberHintWordsShowing++;
  }

  void showFirstLettersHint() {}

  TextSpan _formatForNumberOfWords(int number, String verseText) {
    final wordBoundary = RegExp(r'\b\w', unicode: true);
    int start = 1;

    for (int i = 0; i <= number; i++) {
      start = verseText.indexOf(wordBoundary, start);
      if (start == -1) {
        return TextSpan(
          text: verseText,
          style: const TextStyle(color: Colors.black),
        );
      }
      start++;
    }

    start--;

    final before = verseText.substring(0, start);
    final after = verseText.substring(start);
    final textSpan = TextSpan(children: [
      TextSpan(
        text: before,
        style: const TextStyle(color: Colors.black),
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: Colors.transparent),
      ),
    ]);
    // print(${textSpan.children});

    return textSpan;
  }
}

enum Display {
  initial,
  showingAnswer,
}
