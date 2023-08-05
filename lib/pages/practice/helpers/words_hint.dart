import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

const transparent = Color(0x00000000);

class WordsHintHelper {
  Color _textColor = const Color(0xff000000);
  String _text = '';
  void Function()? onFinished;
  void Function()? _onTap;

  int _numberHintWordsShowing = 0;

  void init({
    required String text,
    required Color textColor,
    required void Function() onTap,
  }) {
    _numberHintWordsShowing = 0;
    _text = text;
    _textColor = textColor;
    _onTap = onTap;
  }

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
      onFinished?.call();
    }

    final textSpan = TextSpan(children: [
      TextSpan(
        text: before,
        style: TextStyle(color: _textColor),
        recognizer:
            (!finished) ? (TapGestureRecognizer()..onTap = _onTap) : null,
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: transparent),
        recognizer:
            (!finished) ? (TapGestureRecognizer()..onTap = _onTap) : null,
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
}
