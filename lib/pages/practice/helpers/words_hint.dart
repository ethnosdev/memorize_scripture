import 'package:flutter/painting.dart';
import 'language_utils.dart';

const transparent = Color(0x00000000);

class WordsHintHelper {
  Color _textColor = const Color(0xff000000);
  String _text = '';
  // int _unitsShowing = 0;
  int _visibleIndex = 0;

  void init({
    required String text,
    required Color textColor,
  }) {
    // _unitsShowing = 0;
    _visibleIndex = 0;
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
    _visibleIndex = _findEndOfCompleteUnit(_visibleIndex, _text);
    if (_visibleIndex >= _text.length) throw OnFinishedException();

    // _unitsShowing++;
    // final revealLimit = _calculateRevealLimit(_unitsShowing, _text);

    // If we can't find a limit, we are already past the end.
    // if (revealLimit == null) throw OnFinishedException();

    // if (_isLastUnit(revealLimit, _text)) {
    //   throw OnFinishedException();
    // }

    // // If skipping the spaces/punctuation after this unit reaches the end of the text,
    // // it means there are no more units to reveal.
    // if (_skipIntermediaryCharacters(revealLimit, _text) >= _text.length) {
    //   throw OnFinishedException();
    // }

    //// Otherwise, return the partial text span.
    return TextSpan(children: [
      TextSpan(
        text: _text.substring(0, _visibleIndex),
        style: TextStyle(color: _textColor),
      ),
      TextSpan(
        text: _text.substring(_visibleIndex),
        style: const TextStyle(color: transparent),
      ),
    ]);
  }

  /// Calculates the string index required to reveal [unitCount] units.
  /// Returns null if the requested count exceeds the available text.
  // int? _calculateRevealLimit(int unitCount, String text) {
  //   if (text.isEmpty) return null;
  //   int index = 0;

  //   for (int i = 0; i < unitCount; i++) {
  //     if (index >= text.length) return null;
  //     index = _findEndOfCompleteUnit(index, text);
  //   }
  //   return index;
  // }

  int _findEndOfCompleteUnit(int start, String text) {
    int index = start;

    // 1. Consume leading whitespace
    while (index < text.length && isWhitespace(text[index])) {
      index++;
    }

    // 2. Consume Prefix Punctuation (e.g., Opening Quote, Parenthesis)
    while (index < text.length && isPrefixPunctuation(text[index])) {
      index++;
    }

    // 3. Consume the "Core"
    if (index < text.length) {
      if (isCjk(text[index])) {
        index++; // CJK core is always exactly one character
      } else {
        // Latin core: letters until we hit whitespace, CJK, or any punctuation
        while (index < text.length &&
            !isWhitespace(text[index]) &&
            !isCjk(text[index]) &&
            !isPrefixPunctuation(text[index]) &&
            !isSuffixPunctuation(text[index])) {
          index++;
        }
      }
    }

    // 4. Consume Suffix Punctuation (e.g., Period, Comma, Closing Quote, Em-dash)
    while (index < text.length && isSuffixPunctuation(text[index])) {
      index++;
    }

    return index;
  }

  bool _isLastUnit(int currentLimit, String text) {
    int nextIndex = _findEndOfCompleteUnit(currentLimit, text);
    // If the next search can't find anything new, we are at the end
    return nextIndex <= currentLimit || nextIndex >= text.length;
  }
}

class OnFinishedException implements Exception {}
