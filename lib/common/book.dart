class Book {
  Book({
    required this.id,
    required this.abbreviation,
    required this.name,
    required this.numberChapters,
    required this.testament,
  });

  final int id;
  final String abbreviation;
  final String name;
  final int numberChapters;
  final Testament testament;
}

enum Testament { ot, nt }
