import 'package:flutter/widgets.dart';

sealed class AnswerContent {
  TextSpan get textSpan;
}

class EmptyAnswer extends AnswerContent {
  @override
  TextSpan get textSpan => const TextSpan();
}

class LettersHint extends AnswerContent {
  LettersHint(this.textSpan);

  @override
  final TextSpan textSpan;
}

class WordsHint extends AnswerContent {
  WordsHint(this.textSpan);

  @override
  final TextSpan textSpan;
}

class NormalText extends AnswerContent {
  NormalText(this.textSpan);

  @override
  final TextSpan textSpan;
}
