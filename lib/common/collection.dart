import 'package:memorize_scripture/common/verse.dart';

class Collection {
  Collection({
    required this.id,
    required this.name,
    this.verses,
  });
  final String id;
  final String name;
  final List<Verse>? verses;
}
