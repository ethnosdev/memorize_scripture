import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class PracticePageManager {
  PracticePageManager({DataRepository? dataRepository}) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
  }
  late final DataRepository dataRepository;

  final promptNotifier = ValueNotifier<String>('');
  final answerNotifier = ValueNotifier<TextSpan>(const TextSpan());
  final isShownNotifier = ValueNotifier<bool>(false);

  List<Verse> _verses = [];

  Future<void> init(String collectionId) async {
    _verses = await dataRepository.fetchVerses(collectionId);
    promptNotifier.value = _verses[0].prompt;
  }

  void show() {
    isShownNotifier.value = true;
    answerNotifier.value = TextSpan(
      text: _verses[0].answer,
      style: const TextStyle(color: Colors.black),
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

  void onResponse(Difficulty response) {
    isShownNotifier.value = false;
    answerNotifier.value = const TextSpan();
    final verse = _verses.removeAt(0);
    if (response == Difficulty.hard) {
      _verses.add(verse);
    }
    promptNotifier.value = (_verses.isEmpty) ? '' : _verses[0].prompt;
  }
}

enum Difficulty { hard, ok, easy }
