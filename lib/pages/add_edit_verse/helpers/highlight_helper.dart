import 'dart:math';

/// Returns the updated text and the new cursor position
///
/// [startIndex] is the starting index of the selection
/// [endIndex] is the ending index of the selection
/// If they are the same, that is the cursor position.
(String, int) updateHighlight(String text, int startIndex, int endIndex) {
  if (startIndex != endIndex) {
    final updated = _highlightRange(text, startIndex, endIndex);
    return (updated, startIndex + 2);
  }
  if (_isHighlighted(text, startIndex)) {
    final updated = _unhighlight(text, startIndex);
    return (updated, startIndex - 2);
  }
  final (start, end) = _getWordRange(text, startIndex);
  if (start == end) return (text, startIndex);
  final updated = _highlightRange(text, start, end);
  return _combineHighlightsSeparatedByWhitespace(updated, startIndex + 2);
}

bool _isHighlighted(String text, int index) {
  bool isHighlighted = false;
  var match = text.indexOf('**');
  while (match != -1 && match < index) {
    isHighlighted = !isHighlighted;
    match = text.indexOf('**', match + 2);
  }
  return isHighlighted;
}

String _unhighlight(String text, int index) {
  final start = max(index - 1, 0);
  final indexBefore = text.lastIndexOf('**', start);
  final indexAfter = text.indexOf('**', index);
  if (indexBefore == -1 || indexAfter == -1) return text;
  return _unhighlightRange(text, indexBefore, indexAfter + 2);
}

String _unhighlightRange(String text, int start, int end) {
  final target = text.substring(start, end);
  final modified = target.replaceAll('*', '');
  return text.substring(0, start) + modified + text.substring(end);
}

String _highlightRange(String text, int start, int end) {
  final before = text.substring(0, start);
  final middle = text.substring(start, end);
  final after = text.substring(end);
  return '$before**$middle**$after';
}

(int start, int end) _getWordRange(String text, int index) {
  int start = index;
  int end = index;
  while (start > 0 && _isWordCharacter(text, start - 1)) {
    start--;
  }
  while (end < text.length && _isWordCharacter(text, end)) {
    end++;
  }
  return (start, end);
}

bool _isWordCharacter(String text, int index) {
  if (index < 0 || index >= text.length) return false;
  final regex = RegExp(r'\w');
  final c = text[index];
  if (c == "'") {
    if (index < 1 || index >= text.length - 1) return false;
    final previous = text[index - 1];
    final next = text[index + 1];
    return regex.hasMatch(previous) && regex.hasMatch(next);
  }
  return regex.hasMatch(c);
}

(String, int) _combineHighlightsSeparatedByWhitespace(
    String inputString, int index) {
  final pattern = RegExp(r'\*\*\s+\*\*');
  final match = pattern.firstMatch(inputString);

  if (match == null) return (inputString, index);

  final startIndex = match.start;
  final endIndex = match.end;
  final substring = inputString.substring(startIndex, endIndex);

  final processedString = inputString.replaceAll(
    substring,
    substring.substring(2, substring.length - 2),
  );

  const asteriskCount = 4;
  int adjustedIndex;
  if (index <= startIndex) {
    adjustedIndex = index;
  } else if (index <= endIndex) {
    adjustedIndex = index - 2;
  } else {
    adjustedIndex = index - asteriskCount;
  }

  return (processedString, adjustedIndex);
}
