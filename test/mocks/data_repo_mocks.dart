import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class EmptyDataRepo implements DataRepository {
  @override
  Future<List<Collection>> fetchCollectionMetadata() async => [];

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async => [];

  @override
  Future<void> updateVerse(String collectionId, Verse verse) {
    throw UnimplementedError();
  }

  @override
  Future<void> batchUpdateVerses(Collection collection) {
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
  Future<List<Collection>> fetchCollectionMetadata() async => [
        Collection(id: 'id', name: 'name'),
      ];

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async => [
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
  Future<void> updateVerse(String collectionId, Verse verse) {
    throw UnimplementedError();
  }

  @override
  Future<void> batchUpdateVerses(Collection collection) {
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
