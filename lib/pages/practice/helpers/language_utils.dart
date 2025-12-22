// \u4e00-\u9fa5: Chinese
// \u3040-\u309f: Hiragana
// \u30a0-\u30ff: Katakana
// \uac00-\ud7af: Hangul
final _cjkRegex =
    RegExp(r'[\u4e00-\u9fa5\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af]');

// Punctuation that attaches to the NEXT word
// Includes standard: “ " ‘ ( [ { <
// Includes CJK: 「 (u300c), 『 (u300e), （ (uff08), 《 (u300a), 【 (u3010)
final _prefixRegex = RegExp(
  r'[“"‘(\[\{<「『（《【]',
  unicode: true,
);

// Punctuation that attaches to the PREVIOUS word
// Includes standard: ” " ’ ) } ] . > ! ? , : ; — -
// Includes CJK: 」 (u300d), 』 (u300f), ） (uff09), 》 (u300b), 】 (u3011),
//     。 (u3002), ， (uff0c), ？ (uff1f), ！ (uff01), ： (uff1a), ； (uff1b)
final _suffixRegex = RegExp(
  r'[”"’)}\]>!?,:;—\-」』）》】。，？！：；]',
  unicode: true,
);

bool isCjk(String text) => _cjkRegex.hasMatch(text);

bool isWhitespace(String char) => RegExp(r'[\s]').hasMatch(char);

/// Punctuation that attaches to the NEXT word (Opening quotes, parentheses, etc.)
bool isPrefixPunctuation(String char) => _prefixRegex.hasMatch(char);

/// Punctuation that attaches to the PREVIOUS word (Closing quotes, period, comma, etc.)
bool isSuffixPunctuation(String char) => _suffixRegex.hasMatch(char);
