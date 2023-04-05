class Verse {
  Verse({
    required this.id,
    required this.prompt,
    required this.answer,
    this.nextDueDate,
    this.interval = Duration.zero,
  });

  /// The UUID of the verse.
  final String id;

  /// The text to show the user to prompt them to say the verse.
  /// This is probably either the verse reference or the previous verse.
  final String prompt;

  /// The verse text to show the user when they ask for the answer to
  /// the prompt.
  final String answer;

  /// The day this verse is due.
  ///
  /// A value of null means that it is a new verse that has never
  /// been practiced before.
  final DateTime? nextDueDate;

  /// The `interval` refers to the length of time from the last practice
  /// to the `nextDueDate`.
  final Duration interval;

  /// Whether this is a new verse that has never been practiced before
  bool get isNew => nextDueDate == null;

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
