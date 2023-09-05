import 'book.dart';

class Version {
  Version({
    required this.name,
    required this.longName,
    required this.abbreviation,
    required this.generateUrl,
  });
  final String name;
  final String longName;
  final String abbreviation;
  final Uri Function(Book book, int chapter) generateUrl;

  Uri urlFor(Book book, int chapter) {
    return generateUrl(book, chapter);
  }
}
