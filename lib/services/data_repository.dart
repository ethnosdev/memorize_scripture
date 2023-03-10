import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/sample_verses.dart';

abstract class DataRepository {
  Future<List<CollectionMetadata>> fetchCollectionMetadata();
  Future<List<Verse>> fetchVerses(String collectionId);
}

class FakeData implements DataRepository {
  @override
  Future<List<CollectionMetadata>> fetchCollectionMetadata() async {
    return [
      CollectionMetadata(id: '001', name: 'Starter pack'),
    ];
  }

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async {
    return starterVersesWeb;
  }
}
