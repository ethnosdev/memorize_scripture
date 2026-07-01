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

    String processedText = _removeBold(text);

    // Ignore white space at the end to prevent an extra step
    int endIndex = processedText.length;
    while (endIndex > 0 && isWhitespace(processedText[endIndex - 1])) {
      endIndex--;
    }
    _text = processedText.substring(0, endIndex);

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

  int _findEndOfCompleteUnit(int start, String text) {
    int index = start;

    // 1. Consume leading whitespace
    while (index < text.length && isWhitespace(text[index])) {
      index++;
    }

    // 2. Consume Prefix Punctuation (e.g., Opening Quote, Parenthesis, Em-dash)
    while (index < text.length) {
      final char = text[index];
      if (isPrefixPunctuation(char)) {
        index++;
        // Also consume any whitespace immediately following prefix punctuation
        // so that it seamlessly connects to the following word.
        while (index < text.length && isWhitespace(text[index])) {
          index++;
        }
      } else {
        break;
      }
    }

    // 3. Consume the "Core"
    if (index < text.length) {
      if (isCjk(text[index])) {
        index++; // CJK core is always exactly one character
      } else {
        // Latin core: letters until we hit whitespace, CJK, or any punctuation
        while (index < text.length) {
          final char = text[index];

          if (isWhitespace(char) || isCjk(char)) {
            break;
          }

          if (isPrefixPunctuation(char) || isSuffixPunctuation(char)) {
            // Special check: keep apostrophes inside a word (e.g., father's or father’s)
            final isApostrophe = char == "'" ||
                char == "’" ||
                char == "‘" ||
                char == "´" ||
                char == "`";
            if (isApostrophe && index + 1 < text.length) {
              final nextChar = text[index + 1];
              final isNextCore = !isWhitespace(nextChar) &&
                  !isCjk(nextChar) &&
                  !isPrefixPunctuation(nextChar) &&
                  !isSuffixPunctuation(nextChar);

              if (isNextCore) {
                index++;
                continue;
              }
            }
            break;
          }

          index++;
        }
      }
    }

    // 4. Consume Suffix Punctuation (e.g., Period, Comma, Closing Quote, Em-dash, Ellipsis)
    while (index < text.length) {
      final char = text[index];
      if (isSuffixPunctuation(char)) {
        index++;
      } else if (isWhitespace(char)) {
        // Check if the space is followed by dots or ellipsis so we can group "Moses, ..." or "Moses, . . ."
        int lookAhead = index;
        while (lookAhead < text.length && isWhitespace(text[lookAhead])) {
          lookAhead++;
        }
        if (lookAhead < text.length &&
            (text[lookAhead] == '.' || text[lookAhead] == '…')) {
          // Attach the space(s) so the subsequent dots become part of this word's suffix
          index++;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return index;
  }
}

class OnFinishedException implements Exception {}
