import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/pages/add_edit_verse/helpers/highlight_helper.dart';

void main() {
  group('Highlight helper:', () {
    test('highlight selection', () {
      const input = 'word';
      final (output, index) = updateHighlight(input, 1, 3);
      expect(output, 'w**or**d');
      expect(index, 3);
    });

    test('highlight word when curser at beginning', () {
      const input = 'a word b';
      final (output, index) = updateHighlight(input, 2, 2);
      expect(output, 'a **word** b');
      expect(index, 4);
    });

    test('highlight word when curser in middle', () {
      const input = 'a word b';
      final (output, index) = updateHighlight(input, 3, 3);
      expect(output, 'a **word** b');
      expect(index, 5);
    });

    test('highlight word when curser at end', () {
      const input = 'a word b';
      final (output, index) = updateHighlight(input, 6, 6);
      expect(output, 'a **word** b');
      expect(index, 8);
    });

    test('highlight words with apostrophes', () {
      const input = "a doesn't b";
      final (output, index) = updateHighlight(input, 2, 2);
      expect(output, "a **doesn't** b");
      expect(index, 4);
    });

    test("don't highlight single quote mark", () {
      const input = "a 'word' b";
      final (output, index) = updateHighlight(input, 4, 4);
      expect(output, "a '**word**' b");
      expect(index, 6);
    });

    test('highlight words with slanted apostrophe', () {
      const input = "a doesn’t b";
      final (output, index) = updateHighlight(input, 2, 2);
      expect(output, "a **doesn’t** b");
      expect(index, 4);
    });

    test("don't highlight right single quote mark", () {
      const input = "a ‘word’ b";
      final (output, index) = updateHighlight(input, 4, 4);
      expect(output, "a ‘**word**’ b");
      expect(index, 6);
    });

    test("combine highlights if only separated by whitespace", () {
      var input = "word **word**";
      var (output, index) = updateHighlight(input, 0, 0);
      expect(output, "**word word**");
      expect(index, 2);

      input = "**word** word";
      (output, index) = updateHighlight(input, 10, 10);
      expect(output, "**word word**");
      expect(index, 8);
    });
  });
}
