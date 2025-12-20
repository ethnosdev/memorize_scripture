// \u4e00-\u9fa5: Chinese
// \u3040-\u309f: Hiragana
// \u30a0-\u30ff: Katakana
// \uac00-\ud7af: Hangul
final _cjkRegex =
    RegExp(r'[\u4e00-\u9fa5\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af]');

bool isCjk(String text) => _cjkRegex.hasMatch(text);

bool isWhitespaceOrPunctuation(String char) {
  return RegExp(r'[\s\-—.,!?;:]').hasMatch(char);
}
