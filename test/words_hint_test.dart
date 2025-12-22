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
      );
      final span = helper.nextWord();
      final text = (span.children!.first as TextSpan).text;
      final color = (span.children!.first as TextSpan).style!.color;
      expect(text, "Hello");
      expect(color, Colors.black);
    });

    test('nextWord should increase count and return correct TextSpan', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello world",
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "Hello");

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should handle hyphens as suffix punctuation', () {
      final helper = WordsHintHelper();
      helper.init(text: "Hello-world", textColor: Colors.black);

      final span1 = helper.nextWord();
      // Reveals "Hello-"
      expect((span1.children!.first as TextSpan).text, "Hello-");

      // Reveals "world" and finishes
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('em dash should count as space', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello—world",
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "Hello—");
    });

    test('hide ** bold markers', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello **world**",
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "Hello");

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('CJK characters should count as individual units', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "你好", // Two Chinese characters
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "你");

      // The second tap should reveal the last character and throw immediately
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('mixed English and CJK should handle boundaries correctly', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "In 泰初", // "In" (English) + space + "泰" + "初"
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "In");

      final span2 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "In"); // "before" text
      // Note: The logic reveals "In 泰". We check the length or substring:
      expect((span2.children!.first as TextSpan).text, "In 泰");

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test(
        'should treat CJK character immediately following English as a new unit',
        () {
      final helper = WordsHintHelper();
      helper.init(
        text: "God愛", // No space between English and Chinese
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "God");

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('trailing punctuation should not require an extra tap', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Hello world!", // Punctuation at the end
        textColor: Colors.black,
      );

      helper.nextWord(); // Reveals "Hello"

      // Second tap reveals "world!" and should throw OnFinishedException
      // immediately because only "!" is left.
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('multiple punctuation marks between words should be skipped', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "Wait... what?",
        textColor: Colors.black,
      );

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "Wait...");

      // Should skip "... " and reveal "what?"
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('single CJK character should throw immediately on first tap', () {
      final helper = WordsHintHelper();
      helper.init(
        text: "愛",
        textColor: Colors.black,
      );

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should attach trailing punctuation to Latin word', () {
      final helper = WordsHintHelper();
      helper.init(text: "Hello, world!", textColor: Colors.black);

      final span = helper.nextWord();
      // Reveals "Hello," including the comma
      expect((span.children!.first as TextSpan).text, "Hello,");
    });

    test('should attach leading and trailing punctuation to Latin word', () {
      final helper = WordsHintHelper();
      helper.init(text: 'He said, "(Hello!)"', textColor: Colors.black);

      var span = helper.nextWord(); // "He"
      var expectedText = (span.children!.first as TextSpan).text;
      expect(expectedText, 'He');

      span = helper.nextWord(); // "He"
      expectedText = (span.children!.first as TextSpan).text;
      expect(expectedText, 'He said,');

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should attach full-width punctuation to CJK character', () {
      final helper = WordsHintHelper();
      helper.init(text: "你好。", textColor: Colors.black);

      helper.nextWord(); // "你"

      // Second tap should reveal "好。" (attaching the Chinese period)
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should attach non-final full-width punctuation to CJK character', () {
      final helper = WordsHintHelper();
      helper.init(text: "你。好", textColor: Colors.black);

      final span1 = helper.nextWord();
      expect((span1.children!.first as TextSpan).text, "你。");

      // Second tap should reveal "好"
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should attach multiple CJK suffix punctuations', () {
      final helper = WordsHintHelper();
      helper.init(text: "好」！", textColor: Colors.black);

      // Should reveal everything in one go because it's a single core + suffixes
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should handle CJK prefix and suffix in one unit', () {
      final helper = WordsHintHelper();
      helper.init(text: "「愛」。", textColor: Colors.black);

      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should handle multiple trailing punctuation marks immediately', () {
      final helper = WordsHintHelper();
      helper.init(text: 'Stop."', textColor: Colors.black);

      // Should reveal 'Stop."' and finish immediately
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });

    test('should reveal prefix punctuation with the word in CJK', () {
      final helper = WordsHintHelper();
      helper.init(text: "「愛」", textColor: Colors.black);

      // Should reveal 「愛」 in one unit
      expect(helper.nextWord, throwsA(isA<OnFinishedException>()));
    });
  });
}
