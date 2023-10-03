import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/pages/practice/helpers/words_hint.dart';

void main() {
  group('WordsHintHelper:', () {
    test('init should correctly initialize fields', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello world",
        textColor: Colors.black,
        onTap: () {},
        onFinished: () {},
      );
      final span = helper.nextWord();
      final text = (span.children!.first as TextSpan).text;
      final color = (span.children!.first as TextSpan).style!.color;
      expect(text, "Hello ");
      expect(color, Colors.black);
    });

    test('nextWord should increase count and return correct TextSpan', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello world",
        textColor: Colors.black,
        onTap: () {},
        onFinished: () {},
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "Hello ");

      final span2 = helper.nextWord();
      expect((span2.children!.first as TextSpan).text, "Hello world");
    });

    test('hide ** bold markers', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello **world**",
        textColor: Colors.black,
        onTap: () {},
        onFinished: () {},
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "Hello ");

      final span2 = helper.nextWord();
      expect((span2.children!.first as TextSpan).text, "Hello world");
    });
  });
}
