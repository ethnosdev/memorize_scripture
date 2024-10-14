import 'package:flutter/painting.dart';

/// Text surrounded by double asterisks should be highlighted.
TextSpan addHighlighting(String text, Color highlightColor) {
  final spans = <TextSpan>[];
  final regExp = RegExp(r'\*\*(.*?)\*\*', dotAll: true);
  int lastEnd = 0;
  final highlightStyle = TextStyle(
    color: highlightColor,
    fontWeight: FontWeight.bold,
  );

  // Find all matches and create TextSpans
  regExp.allMatches(text).forEach((match) {
    spans.add(TextSpan(
      text: text.substring(lastEnd, match.start),
    ));
    spans.add(TextSpan(
      text: match.group(1),
      style: highlightStyle,
    ));
    lastEnd = match.end;
  });

  // Add the remaining text if any
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd, text.length),
    ));
  }

  return TextSpan(children: spans);
}
