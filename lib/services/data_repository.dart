import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/sample_verses.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DataRepository {
  /// Returns collections without the verses.
  Future<List<Collection>> fetchCollectionMetadata();

  /// Returns verses in a collection
  Future<List<Verse>> fetchVerses(String collectionId);

  /// Returns a single verse from a collection
  Future<Verse> fetchVerse({
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

// class SharedPrefsDataRepo implements DataRepository {
//   @override
//   Future<void> batchUpdateVerses(Collection collection) async {
//     assert(collection.verses != null, 'The collection verses cannot be null.');
//     final prefs = await SharedPreferences.getInstance();
//     prefs.
//   }

//   @override
//   Future<List<Collection>> fetchCollectionMetadata() async {
//     // TODO: implement fetchCollectionMetadata
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<Verse>> fetchVerses(String collectionId) async {
//     // TODO: implement fetchVerses
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> updateVerse(String collectionId, Verse verse) async {
//     // TODO: implement updateVerse
//     throw UnimplementedError();
//   }
// }

class FakeData implements DataRepository {
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
