import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/pages/practice/helpers/letters_hint.dart';

void main() {
  group('LettersHintHelper:', () {
    test('textSpan should return the expected TextSpan', () {
      final helper = LettersHintHelper(
        text: "Hello, World!",
        textColor: Colors.black,
        onUpdate: null,
      );
      final span = helper.textSpan;
      final texts = span.children!.map((e) => (e as TextSpan).text!).toList();
      expect(texts, ["H", "ello", ", ", "W", "orld", "!"]);
    });

    test('count normal apostrophe as part of word', () {
      final helper = LettersHintHelper(
        text: "David's",
        textColor: Colors.black,
        onUpdate: null,
      );
      final span = helper.textSpan;
      final texts = span.children!.map((e) => (e as TextSpan).text!).toList();
      expect(texts, ["D", "avid's"]);
    });

    test('count smart apostrophe as part of word', () {
      final helper = LettersHintHelper(
        text: "David’s",
        textColor: Colors.black,
        onUpdate: null,
      );
      final span = helper.textSpan;
      final texts = span.children!.map((e) => (e as TextSpan).text!).toList();
      expect(texts, ["D", "avid’s"]);
    });
  });
}
