import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class EmptyDataRepo implements DataRepository {
  @override
  Future<List<CollectionMetadata>> fetchCollectionMetadata() async => [];

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async => [];
}

class MockDataRepo implements DataRepository {
  @override
  Future<List<CollectionMetadata>> fetchCollectionMetadata() async => [
        CollectionMetadata(id: 'id', name: 'name'),
      ];

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async => [
        Verse(translation: 'ABC', prompt: 'a 1', answer: 'one two three'),
        Verse(translation: 'ABC', prompt: 'a 2', answer: 'four five six'),
      ];
}
