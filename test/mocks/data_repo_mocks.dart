import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class EmptyDataRepo implements DataRepository {
  @override
  Future<void> batchInsertVerses(
      {required Collection collection, required List<Verse> verses}) async {}

  @override
  Future<void> deleteCollection({required String collectionId}) async {}

  @override
  Future<void> deleteVerse({required String verseId}) async {}

  @override
  Future<List<Verse>> fetchAllVerses([String? collectionId]) async => [];

  @override
  Future<List<Collection>> fetchCollections() async => [];

  @override
  Future<List<Verse>> fetchTodaysVerses({
    String? collectionId,
    int? newVerseLimit,
  }) async =>
      [];

  @override
  Future<Verse?> fetchVerse({required String verseId}) async => null;

  @override
  Future<void> init() async {}

  @override
  Future<void> insertCollection(Collection collection) async {}

  @override
  Future<void> updateCollection(Collection collection) async {}

  @override
  Future<void> insertVerse(String collectionId, Verse verse) async {}

  @override
  Future<void> updateVerse(String collectionId, Verse verse) async {}

  @override
  Future<bool> promptExists({
    required String collectionId,
    required String prompt,
  }) async {
    return false;
  }

  @override
  Future<int> numberInCollection(String collectionId) async => 0;
}

class MockDataRepo implements DataRepository {
  @override
  Future<void> init() async {}

  @override
  Future<List<Collection>> fetchCollections() async => [
        Collection(id: 'id', name: 'name'),
      ];

  @override
  Future<void> insertVerse(String collectionId, Verse verse) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateVerse(String collectionId, Verse verse) {
    throw UnimplementedError();
  }

  @override
  Future<void> batchInsertVerses(
      {required Collection collection, required List<Verse> verses}) {
    // TODO: implement batchInsertVerses
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCollection({required String collectionId}) {
    // TODO: implement deleteCollection
    throw UnimplementedError();
  }

  @override
  Future<void> deleteVerse({required String verseId}) {
    // TODO: implement deleteVerse
    throw UnimplementedError();
  }

  @override
  Future<List<Verse>> fetchAllVerses([String? collectionId]) async => [
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
  Future<List<Verse>> fetchTodaysVerses(
      {String? collectionId, int? newVerseLimit}) {
    // TODO: implement fetchTodaysVerses
    throw UnimplementedError();
  }

  @override
  Future<Verse?> fetchVerse({required String verseId}) {
    // TODO: implement fetchVerse
    throw UnimplementedError();
  }

  @override
  Future<void> insertCollection(Collection collection) {
    // TODO: implement upsertCollection
    throw UnimplementedError();
  }

  @override
  Future<void> updateCollection(Collection collection) {
    // TODO: implement upsertCollection
    throw UnimplementedError();
  }

  @override
  Future<bool> promptExists({
    required String collectionId,
    required String prompt,
  }) {
    // TODO: implement promptExists
    throw UnimplementedError();
  }

  @override
  Future<int> numberInCollection(String collectionId) {
    // TODO: implement numberInCollection
    throw UnimplementedError();
  }
}
