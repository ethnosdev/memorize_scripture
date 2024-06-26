import 'package:flutter/painting.dart';

const transparent = Color(0x00000000);

class WordsHintHelper {
  Color _textColor = const Color(0xff000000);
  String _text = '';

  int _numberHintWordsShowing = 0;

  void init({
    required String text,
    required Color textColor,
  }) {
    _numberHintWordsShowing = 0;
    _text = _removeBold(text);
    _textColor = textColor;
  }

  String _removeBold(String text) {
    return text.replaceAll('**', '');
  }

  /// Returns a text span with the next word visible.
  ///
  /// Throws an OnFinishedException if showing the next word would
  /// cause the text to be finished.
  TextSpan nextWord() {
    _numberHintWordsShowing++;
    final textSpan = _formatForNumberOfWords(
      _numberHintWordsShowing,
      _text,
    );
    return textSpan;
  }

  TextSpan _formatForNumberOfWords(int number, String verseText) {
    if (verseText.isEmpty) return const TextSpan(text: '');

    final index = _indexAfterNthSpace(number, verseText);
    final before = verseText.substring(0, index);
    final after = (index == null) ? '' : verseText.substring(index);

    final finished = index == null;
    if (finished) {
      throw OnFinishedException();
    }

    final textSpan = TextSpan(children: [
      TextSpan(
        text: before,
        style: TextStyle(color: _textColor),
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: transparent),
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
    final nonWhiteSpace = RegExp(r'[^\s\-—]');
    final index = text.indexOf(nonWhiteSpace, start);
    return (index < 0) ? null : index;
  }

  int? _advanceToNextWhiteSpace(int start, String text) {
    // counting hyphens and em dashes as white space
    final whiteSpace = RegExp(r'[\s\-—]');
    final index = text.indexOf(whiteSpace, start);
    return (index < 0) ? null : index;
  }
}

class OnFinishedException implements Exception {}
