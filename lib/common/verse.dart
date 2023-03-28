class Verse {
  Verse({
    this.id,
    required this.prompt,
    required this.answer,
    this.nextDueDate = defaultNextDueDate,
    this.consecutiveCorrect = defaultConsecutiveCorrect,
    this.easinessFactor = defaultEasinessFactor,
    this.qualityAssessment = defaultQualityAssessment,
    this.isFirstViewToday = true,
  });

  static const int defaultNextDueDate = 0;
  static const int defaultConsecutiveCorrect = 0;
  static const double defaultEasinessFactor = 2.5;
  static const int defaultQualityAssessment = 0;

  final String? id;
  final String prompt;
  final String answer;
  final int nextDueDate;
  final int consecutiveCorrect;
  final double easinessFactor;
  final int qualityAssessment;
  final bool isFirstViewToday;
}
