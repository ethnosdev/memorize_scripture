import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class EmptyDataRepo implements DataRepository {
  @override
  Future<List<CollectionMetadata>> fetchCollectionMetadata() async => [];

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async => [];
}
