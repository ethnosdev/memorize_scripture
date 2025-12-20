import 'package:flutter/painting.dart';
import 'language_utils.dart';

const transparent = Color(0x00000000);

class WordsHintHelper {
  Color _textColor = const Color(0xff000000);
  String _text = '';
  int _unitsShowing = 0;

  void init({
    required String text,
    required Color textColor,
  }) {
    _unitsShowing = 0;
    _text = _removeBold(text);
    _textColor = textColor;
  }

  String _removeBold(String text) {
    return text.replaceAll('**', '');
  }

  /// Returns a text span with the next logical unit (word or CJK character) visible.
  ///
  /// Throws an [OnFinishedException] if this is the last unit or if
  /// no more units are available.
  TextSpan nextWord() {
    _unitsShowing++;
    final revealLimit = _calculateRevealLimit(_unitsShowing, _text);

    // If we can't find a limit, we are already past the end.
    if (revealLimit == null) {
      throw OnFinishedException();
    }

    // If skipping the spaces/punctuation after this unit reaches the end of the text,
    // it means there are no more units to reveal.
    if (_skipIntermediaryCharacters(revealLimit, _text) >= _text.length) {
      throw OnFinishedException();
    }

    //// Otherwise, return the partial text span.
    return TextSpan(children: [
      TextSpan(
        text: _text.substring(0, revealLimit),
        style: TextStyle(color: _textColor),
      ),
      TextSpan(
        text: _text.substring(revealLimit),
        style: const TextStyle(color: transparent),
      ),
    ]);
  }

  /// Calculates the string index required to reveal [unitCount] units.
  /// Returns null if the requested count exceeds the available text.
  int? _calculateRevealLimit(int unitCount, String text) {
    if (text.isEmpty) return null;

    int currentIndex = 0;

    for (int i = 0; i < unitCount; i++) {
      // 1. Skip over leading whitespace/punctuation to find the start of the next unit
      currentIndex = _skipIntermediaryCharacters(currentIndex, text);

      if (currentIndex >= text.length) return null;

      // 2. Find where this specific unit ends
      currentIndex = _findNextUnitBoundary(currentIndex, text);
    }

    return currentIndex;
  }

  /// Determines the end index of the unit starting at [start].
  int _findNextUnitBoundary(int start, String text) {
    if (start >= text.length) return text.length;

    final char = text[start];

    // If it's a CJK character, the unit is exactly one character long.
    if (isCjk(char)) {
      return start + 1;
    }

    // If it's Latin/Other, the unit ends at the next whitespace or the start of a CJK block.
    int index = start;
    while (index < text.length) {
      final nextChar = text[index];
      if (isWhitespaceOrPunctuation(nextChar) || isCjk(nextChar)) {
        break;
      }
      index++;
    }
    return index;
  }

  /// Moves the index past any characters that don't constitute a "unit" (e.g., spaces).
  int _skipIntermediaryCharacters(int start, String text) {
    int index = start;
    while (index < text.length && isWhitespaceOrPunctuation(text[index])) {
      index++;
    }
    return index;
  }
}

class OnFinishedException implements Exception {}
