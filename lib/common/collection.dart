class Collection {
  Collection({
    required this.id,
    required this.name,
    this.isPinned = false,
    required this.studyStyle,
    this.versesPerDay = defaultVersesPerDay,
    required this.createdDate,
  });

  /// The unique ID of the collection in UUID format.
  final String id;

  /// The name of the collection.
  final String name;

  /// Whether the collection is pinned to the top of the list.
  final bool isPinned;

  /// Whether to study the collection by date or by a fixed number
  /// of verses per day.
  final StudyStyle studyStyle;

  /// Only used for StudyStyle.fixedReview.
  final int versesPerDay;

  /// The date the collection was created.
  final DateTime createdDate;

  static const defaultVersesPerDay = 5;

  Collection copyWith({
    String? id,
    String? name,
    bool? isPinned,
    StudyStyle? studyStyle,
    int? versesPerDay,
    DateTime? createdDate,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      isPinned: isPinned ?? this.isPinned,
      studyStyle: studyStyle ?? this.studyStyle,
      versesPerDay: versesPerDay ?? this.versesPerDay,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

enum StudyStyle {
  reviewByDate('date'),
  fixedReview('fixed');

  const StudyStyle(this.value);
  final String value;

  static StudyStyle fromValue(String? value) {
    if (value == null) {
      return StudyStyle.reviewByDate;
    }
    return StudyStyle.values.firstWhere(
      (style) => style.value == value,
      orElse: () => StudyStyle.reviewByDate,
    );
  }
}
