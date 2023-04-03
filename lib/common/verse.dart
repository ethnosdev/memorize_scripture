class Verse {
  Verse({
    this.id,
    required this.prompt,
    required this.answer,
    this.nextDueDate,
    this.interval = Duration.zero,
  });

  final String? id;
  final String prompt;
  final String answer;
  final DateTime? nextDueDate;
  final Duration interval;

  Verse copyWith({
    String? id,
    String? prompt,
    String? answer,
    DateTime? nextDueDate,
    Duration? interval,
  }) {
    return Verse(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      answer: answer ?? this.answer,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      interval: interval ?? this.interval,
    );
  }
}
