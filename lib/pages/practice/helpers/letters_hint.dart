import 'package:flutter/painting.dart';

class LettersHintHelper {
  LettersHintHelper({
    required this.text,
    required this.textColor,
  });
  final String text;
  final Color textColor;

  TextSpan get textSpan {
    final latinChar = RegExp(r'\w');
    final result = StringBuffer();
    bool isWordStart = true;
    for (int i = 0; i < text.length; i++) {
      final character = text[i];
      final isWordChar = character.contains(latinChar);
      if (!isWordChar || isWordStart) {
        result.write(character);
        isWordStart = !isWordChar;
      }
    }
    return TextSpan(
      text: result.toString(),
      style: TextStyle(color: textColor),
    );
  }
}
