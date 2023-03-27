import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/sample_verses.dart';

abstract class DataRepository {
  Future<void> init();

  /// Returns collections without the verses.
  Future<List<Collection>> fetchCollectionMetadata();

  /// Returns verses in a collection
  Future<List<Verse>> fetchVerses(String collectionId);

  /// Returns a single verse from a collection
  Future<Verse?> fetchVerse({
    required String collectionId,
    required String verseId,
  });

  /// Updates a verse in the collection
  ///
  /// If the verse already exists (based on the verse id), then it will
  /// perform an update. Otherwise, it will add it.
  Future<void> updateVerse(String collectionId, Verse verse);

  /// Updates many verses at once
  ///
  /// If a verse already exists (based on the verse id), then it will
  /// perform an update. Otherwise, it will add it.
  ///
  /// The collection verses cannot be null.
  Future<void> batchUpdateVerses(Collection collection);
}

class FakeData implements DataRepository {
  @override
  Future<void> init() async {
    // do nothing
  }

  @override
  Future<List<Collection>> fetchCollectionMetadata() async {
    return [
      Collection(id: '001', name: 'Starter pack'),
    ];
  }

  @override
  Future<List<Verse>> fetchVerses(String collectionId) async {
    return starterVersesWeb;
  }

  @override
  Future<Verse> fetchVerse({
    required String collectionId,
    required String verseId,
  }) async {
    return starterVersesWeb.first;
  }

  @override
  Future<void> updateVerse(
    String collectionId,
    Verse verse,
  ) async {
    // ignore
  }

  @override
  Future<void> batchUpdateVerses(Collection collection) async {
    // ignore
  }
}
