import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';

abstract class DataRepository {
  Future<void> init();

  /// Returns all collections
  Future<List<Collection>> fetchCollections();

  /// Returns all verses in a collection
  ///
  /// Defaults to all verses in the app if no collection is specified
  Future<List<Verse>> fetchAllVerses([String? collectionId]);

  /// Returns verses that are due today
  ///
  /// `limit` specifies the max number of new verses to return. If null,
  /// then all new verses in the collection are returned.
  Future<List<Verse>> fetchTodaysVerses({
    required String collectionId,
    int? limit,
  });

  /// Returns a single verse
  Future<Verse?> fetchVerse({required String verseId});

  /// Inserts a new verse in the collection
  Future<void> insertVerse(String collectionId, Verse verse);

  /// Updates a verse in the collection
  ///
  /// The verse id is used to look up the verse.
  Future<void> updateVerse(String collectionId, Verse verse);

  /// Inserts many verses at once
  Future<void> batchInsertVerses({
    required Collection collection,
    required List<Verse> verses,
  });

  /// Deletes a verse
  Future<void> deleteVerse({required String verseId});

  /// Inserts a new collection
  Future<void> insertCollection(Collection collection);

  /// Updates the collection
  ///
  /// The id is used to update the collection
  Future<void> updateCollection(Collection collection);

  /// Deletes a collection
  Future<void> deleteCollection({required String collectionId});

  /// Check whether the prompt exists
  Future<bool> promptExists(String prompt);
}
