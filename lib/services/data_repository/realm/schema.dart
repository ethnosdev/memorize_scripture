import 'package:realm/realm.dart';

part 'schema.g.dart';

@RealmModel()
class _RealmCollection {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late List<_RealmVerse> verses;
}

@RealmModel()
class _RealmVerse {
  late ObjectId id;
  late String prompt;
  late String answer;
}
