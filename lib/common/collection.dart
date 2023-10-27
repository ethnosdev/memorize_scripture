class Collection {
  Collection({
    required this.id,
    required this.name,
    this.isPinned = false,
  });
  final String id;
  final String name;
  final bool isPinned;

  Collection copyWith({
    String? id,
    String? name,
    bool? isPinned,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
