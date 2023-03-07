import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';

abstract class DataRepository {
  Future<List<CollectionMetadata>> fetchCollectionMetadata();
  Future<List<Verse>> fetchVerses(String collectionId);
}

class FakeData implements DataRepository {
  @override
  Future<List<CollectionMetadata>> fetchCollectionMetadata() async {
    return [
      CollectionMetadata(id: '001', name: 'Navigator verse pack'),
      CollectionMetadata(id: '002', name: 'Proverbs 3'),
      CollectionMetadata(id: '003', name: 'John 15'),
    ];
  }

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async {
    return [
      Verse(
        translation: 'ESV',
        prompt: 'John 15:1',
        answer: 'I am the true vine and my father is the vinedresser. (ESV)',
      ),
    ];
  }
}
