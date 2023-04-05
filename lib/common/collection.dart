class Collection {
  Collection({
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  Collection copyWith({
    String? id,
    String? name,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
