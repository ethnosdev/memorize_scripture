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
  /// `newVerseLimit` specifies the max number of new verses to return. If null,
  /// then all new verses in the collection are returned.
  Future<List<Verse>> fetchTodaysVerses({
    required String collectionId,
    int? newVerseLimit,
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
  Future<bool> promptExists({
    required String collectionId,
    required String prompt,
  });

  /// Return the number of verses in the collection, regardless of due date.
  Future<int> numberInCollection(String collectionId);

  /// Return all of the database rows for the collections table.
  /// This is useful for backup.
  /// If collectionId is provided then only return one row.
  Future<List<Map<String, Object?>>> dumpCollections([String? collectionId]);

  /// Return all of the database rows for the verses table.
  /// This is useful for backup.
  /// If collectionId is provided then only return verse rows for this
  /// collection.
  Future<List<Map<String, Object?>>> dumpVerses([String? collectionId]);

  /// Restores collections from a backup in JSON form.
  /// Returns the number of collections added.
  Future<int> restoreCollections(List<Map<String, Object?>> collections);

  /// Restores verses from a backup in JSON form.
  /// Returns the number of verses added and updated.
  Future<(int added, int updated, int errorCount)> restoreVerses(
      List<Map<String, Object?>> verses);

  /// Resets all the due dates in the collection and makes verses like new.
  /// Returns the number of verses updated.
  Future<int> resetDueDates({required String collectionId});
}
