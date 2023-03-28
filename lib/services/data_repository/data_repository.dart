import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/sample_verses.dart';

abstract class DataRepository {
  Future<void> init();

  /// Returns all collections
  Future<List<Collection>> fetchCollections();

  /// Returns all verses in a collection
  ///
  /// Defaults to all verses in the app if no collection is specified
  Future<List<Verse>> fetchAllVerses({String? collectionId});

  /// Returns verses that are due today
  ///
  /// If `collectionId` is omitted then all verses are returned.
  /// `limit` specifies the max number of verses to return.
  Future<List<Verse>> fetchTodaysVerses({String? collectionId, int? limit});

  /// Returns a single verse
  Future<Verse?> fetchVerse({required String verseId});

  /// Updates or inserts a verse in the collection
  ///
  /// If the verse id is null and the prompt is doesn't exist then inserts.
  Future<void> upsertVerse(String collectionId, Verse verse);

  /// Inserts many verses at once
  ///
  /// If a verse already exists (based on the verse id), then it will
  /// perform an update. Otherwise, it will add it.
  Future<void> batchInsertVerses({
    required Collection collection,
    required List<Verse> verses,
  });

  /// Deletes a verse
  Future<void> deleteVerse({required String verseId});

  /// Update or insert collection
  ///
  /// If id is null and the name doesn't exist then inserts new collection
  Future<void> upsertCollection(Collection collection);

  /// Deletes a collection
  Future<void> deleteCollection({required String collectionId});
}

// class FakeData implements DataRepository {
//   @override
//   Future<void> init() async {
//     // do nothing
//   }

//   @override
//   Future<List<Collection>> fetchCollections() async {
//     return [
//       Collection(id: '001', name: 'Starter pack'),
//     ];
//   }

//   @override
//   Future<List<Verse>> fetchAllVerses(String collectionId) async {
//     return starterVersesWeb;
//   }

//   @override
//   Future<Verse> fetchVerse({
//     required String collectionId,
//     required String verseId,
//   }) async {
//     return starterVersesWeb.first;
//   }

//   @override
//   Future<void> upsertVerse(
//     String collectionId,
//     Verse verse,
//   ) async {
//     // ignore
//   }

//   @override
//   Future<void> batchInsertVerses(Collection collection) async {
//     // ignore
//   }
// }
