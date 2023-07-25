import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LettersHintHelper {
  LettersHintHelper({
    required this.text,
    required this.textColor,
    required this.onUpdate,
  }) {
    _tokens = _findGroups(text);
  }
  final String text;
  final Color textColor;
  final void Function(TextSpan span)? onUpdate;
  late List<_Token> _tokens;

  TextSpan get textSpan {
    return TextSpan(
      children: [
        ..._tokens.map((token) => token.toTextSpan()),
      ],
    );
  }

  List<_Token> _findGroups(String str) {
    final list = <_Token>[];
    RegExp exp = RegExp(r"(\b\w+('\w+)?\b)|(\W+)");

    var matches = exp.allMatches(str);
    int tokenId = 0;
    for (var match in matches) {
      final group1 = match.group(1);
      final group3 = match.group(3);
      if (group1 != null) {
        final firstLetter = group1.characters.first;
        final firstLetterToken = _Token(
          id: tokenId,
          text: firstLetter,
          textColor: textColor,
          onUpdate: _updateSpans,
        );
        list.add(firstLetterToken);

        final remainingLetters = group1.characters.skip(1).toString();
        final remainingLettersToken = _Token(
          id: tokenId,
          text: remainingLetters,
          textColor: Colors.transparent,
          onUpdate: _updateSpans,
        );
        list.add(remainingLettersToken);
      }
      if (group3 != null) {
        final nonWord = _Token(
          id: tokenId,
          text: group3,
          textColor: textColor,
          onUpdate: _updateSpans,
        );
        list.add(nonWord);
        tokenId++;
      }
    }
    return list;
  }

  void _updateSpans(int id) {
    for (int index = 0; index < _tokens.length; index++) {
      final token = _tokens[index];
      if (token.id == id) {
        final updatedToken = _Token(
          id: id,
          text: token.text,
          textColor: textColor,
          onUpdate: token.onUpdate,
        );
        _tokens[index] = updatedToken;
      }
    }

    onUpdate?.call(textSpan);
  }
}

class _Token {
  _Token({
    required this.id,
    required this.text,
    required this.textColor,
    required this.onUpdate,
  });
  final int id;
  final String text;
  final Color textColor;
  final Function(int id) onUpdate;

  TextSpan toTextSpan() {
    return TextSpan(
      recognizer: TapGestureRecognizer()..onTap = () => onUpdate.call(id),
      text: text,
      style: TextStyle(color: textColor),
    );
  }
}
