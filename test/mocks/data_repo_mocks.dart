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
    int? limit,
  }) async =>
      [];

  @override
  Future<Verse?> fetchVerse({required String verseId}) async => null;

  @override
  Future<void> init() async {}

  @override
  Future<void> upsertCollection(Collection collection) async {}

  @override
  Future<void> upsertVerse(String collectionId, Verse verse) async {}

  @override
  Future<void> moveCollection(int oldIndex, int newIndex) async {}
}

class MockDataRepo implements DataRepository {
  @override
  Future<void> init() async {}

  @override
  Future<List<Collection>> fetchCollections() async => [
        Collection(id: 'id', name: 'name'),
      ];

  @override
  Future<void> upsertVerse(String collectionId, Verse verse) {
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
          prompt: 'a 1',
          answer: 'one two three',
        ),
        Verse(
          prompt: 'a 2',
          answer: 'four five six',
        ),
      ];

  @override
  Future<List<Verse>> fetchTodaysVerses({String? collectionId, int? limit}) {
    // TODO: implement fetchTodaysVerses
    throw UnimplementedError();
  }

  @override
  Future<Verse?> fetchVerse({required String verseId}) {
    // TODO: implement fetchVerse
    throw UnimplementedError();
  }

  @override
  Future<void> upsertCollection(Collection collection) {
    // TODO: implement upsertCollection
    throw UnimplementedError();
  }

  @override
  Future<void> moveCollection(int oldIndex, int newIndex) {
    // TODO: implement moveCollection
    throw UnimplementedError();
  }
}
