import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class EmptyDataRepo implements DataRepository {
  @override
  Future<void> init() async {}

  @override
  Future<List<Collection>> fetchCollections() async => [];

  @override
  Future<List<Verse>> fetchAllVerses(String collectionId) async => [];

  @override
  Future<void> upsertVerse(String collectionId, Verse verse) {
    throw UnimplementedError();
  }

  @override
  Future<void> batchInsertVerses(Collection collection) {
    throw UnimplementedError();
  }

  @override
  Future<Verse> fetchVerse({
    required String collectionId,
    required String verseId,
  }) {
    throw UnimplementedError();
  }
}

class MockDataRepo implements DataRepository {
  @override
  Future<void> init() async {}

  @override
  Future<List<Collection>> fetchCollections() async => [
        Collection(id: 'id', name: 'name'),
      ];

  @override
  Future<List<Verse>> fetchAllVerses(String collectionId) async => [
        Verse(
          id: '0',
          prompt: 'a 1',
          answer: 'one two three',
        ),
        Verse(
          id: '1',
          prompt: 'a 2',
          answer: 'four five six',
        ),
      ];

  @override
  Future<void> upsertVerse(String collectionId, Verse verse) {
    throw UnimplementedError();
  }

  @override
  Future<void> batchInsertVerses(Collection collection) {
    throw UnimplementedError();
  }

  @override
  Future<Verse> fetchVerse({
    required String collectionId,
    required String verseId,
  }) {
    throw UnimplementedError();
  }
}
