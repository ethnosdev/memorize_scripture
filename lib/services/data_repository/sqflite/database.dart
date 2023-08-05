import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/data_repository/sqflite/schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorage implements DataRepository {
  final String _databaseName = "database.db";
  static const int _databaseVersion = 1;
  late Database _database;

  @override
  Future<void> init() async {
    final path = join(await getDatabasesPath(), _databaseName);
    debugPrint('init: $path');
    _database = await openDatabase(
      path,
      onCreate: _onCreate,
      version: _databaseVersion,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(CollectionEntry.createCollectionTable);
    await db.execute(VerseEntry.createVocabTable);
  }

  @override
  Future<List<Collection>> fetchCollections() async {
    final collections = await _database.query(
      CollectionEntry.collectionTable,
      orderBy: 'LOWER(${CollectionEntry.name}) ASC',
    );
    return List.generate(collections.length, (i) {
      return Collection(
        id: collections[i][CollectionEntry.id] as String,
        name: collections[i][CollectionEntry.name] as String,
      );
    });
  }

  @override
  Future<List<Verse>> fetchAllVerses([String? collectionId]) async {
    List<Map<String, Object?>> verses;
    if (collectionId != null) {
      verses = await _database.query(
        VerseEntry.verseTable,
        where: '${VerseEntry.collectionId} = ?',
        whereArgs: [collectionId],
      );
    } else {
      verses = await _database.query(VerseEntry.verseTable);
    }
    return List.generate(verses.length, (i) {
      final verse = verses[i];
      return Verse(
        id: verse[VerseEntry.id] as String,
        prompt: verse[VerseEntry.prompt] as String,
        text: verse[VerseEntry.verseText] as String,
        nextDueDate: _dbVerseToDate(verse),
        interval: _dbVerseToInterval(verse),
      );
    });
  }

  Future<void> _updateCollectionAccessTime(String collectionId) async {
    final timestamp = _timestampNow();
    await _database.update(
      CollectionEntry.collectionTable,
      {CollectionEntry.accessedDate: timestamp},
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
  }

  DateTime? _dbVerseToDate(Map<String, Object?> verse) {
    final timestamp = verse[VerseEntry.nextDueDate] as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  Duration _dbVerseToInterval(Map<String, Object?> verse) {
    final days = verse[VerseEntry.interval] as int;
    return Duration(days: days);
  }

  @override
  Future<List<Verse>> fetchTodaysVerses({
    required String collectionId,
    int? newVerseLimit,
  }) async {
    final newVerses = await _fetchNewVerses(collectionId, newVerseLimit);
    final reviewVerses = await _fetchReviewVerses(collectionId);
    _updateCollectionAccessTime(collectionId);
    final verses = [...newVerses, ...reviewVerses];
    return List.generate(verses.length, (i) {
      final verse = verses[i];
      return Verse(
        id: verse[VerseEntry.id] as String,
        prompt: verse[VerseEntry.prompt] as String,
        text: verse[VerseEntry.verseText] as String,
        nextDueDate: _dbVerseToDate(verse),
        interval: _dbVerseToInterval(verse),
      );
    });
  }

  Future<List<Map<String, Object?>>> _fetchNewVerses(
    String collectionId,
    int? limit,
  ) async {
    return await _database.query(
      VerseEntry.verseTable,
      where: '${VerseEntry.collectionId} = ? '
          'AND ${VerseEntry.nextDueDate} IS NULL',
      whereArgs: [collectionId],
      orderBy: '${VerseEntry.prompt} ASC',
      limit: limit,
    );
  }

  Future<List<Map<String, Object?>>> _fetchReviewVerses(
      String collectionId) async {
    final today = _timestampNow();
    return await _database.query(
      VerseEntry.verseTable,
      where: '${VerseEntry.collectionId} = ? '
          'AND ${VerseEntry.nextDueDate} <= ?',
      whereArgs: [collectionId, today],
      orderBy: '${VerseEntry.prompt} ASC',
    );
  }

  @override
  Future<Verse?> fetchVerse({required String verseId}) async {
    final results = await _database.query(
      VerseEntry.verseTable,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
    if (results.isEmpty) return null;
    final verse = results.first;
    return Verse(
      id: verse[VerseEntry.id] as String,
      prompt: verse[VerseEntry.prompt] as String,
      text: verse[VerseEntry.verseText] as String,
      nextDueDate: _dbVerseToDate(verse),
      interval: _dbVerseToInterval(verse),
    );
  }

  @override
  Future<void> insertVerse(String collectionId, Verse verse) async {
    await _database.insert(
      VerseEntry.verseTable,
      {
        VerseEntry.id: verse.id,
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.verseText: verse.text,
        VerseEntry.modifiedDate: _timestampNow(),
        VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
        VerseEntry.interval: verse.interval.inDays,
      },
    );
  }

  @override
  Future<void> updateVerse(String collectionId, Verse verse) async {
    await _database.update(
      VerseEntry.verseTable,
      {
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.verseText: verse.text,
        VerseEntry.modifiedDate: _timestampNow(),
        VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
        VerseEntry.interval: verse.interval.inDays,
      },
      where: '${VerseEntry.id} = ?',
      whereArgs: [verse.id],
    );
  }

  int _timestampNow() => _dateToSecondsSinceEpoch(DateTime.now())!;

  int? _dateToSecondsSinceEpoch(DateTime? date) {
    if (date == null) return null;
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  Future<void> batchInsertVerses({
    required Collection collection,
    required List<Verse> verses,
    Database? database,
  }) async {
    final db = database ?? _database;
    final batch = db.batch();
    final timestamp = _timestampNow();
    for (Verse verse in verses) {
      batch.insert(
        VerseEntry.verseTable,
        {
          VerseEntry.id: verse.id,
          VerseEntry.collectionId: collection.id,
          VerseEntry.prompt: verse.prompt,
          VerseEntry.verseText: verse.text,
          VerseEntry.modifiedDate: timestamp,
          VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
          VerseEntry.interval: verse.interval.inDays,
        },
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteVerse({required String verseId}) async {
    await _database.delete(
      VerseEntry.verseTable,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
  }

  @override
  Future<void> insertCollection(Collection collection) async {
    await _upsertCollection(collection);
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    await _upsertCollection(collection);
  }

  Future<void> _upsertCollection(Collection collection) async {
    // Check if another collection has the same name
    final results = await _database.query(
      CollectionEntry.collectionTable,
      where: '${CollectionEntry.name} = ?',
      whereArgs: [collection.name.trim()],
    );
    if (results.isNotEmpty &&
        results.first[CollectionEntry.id] != collection.id) {
      debugPrint('Don\'t allow duplicate collection names');
      return;
    }

    // Insert or replace the collection
    await _database.insert(
      CollectionEntry.collectionTable,
      {
        CollectionEntry.id: collection.id,
        CollectionEntry.name: collection.name.trim(),
        CollectionEntry.accessedDate: _timestampNow(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCollection({required String collectionId}) async {
    await _database.delete(
      CollectionEntry.collectionTable,
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
    await _database.delete(
      VerseEntry.verseTable,
      where: '${VerseEntry.collectionId} = ?',
      whereArgs: [collectionId],
    );
  }

  @override
  Future<bool> promptExists({
    required String collectionId,
    required String prompt,
  }) async {
    final results = await _database.query(
      VerseEntry.verseTable,
      where: '${VerseEntry.collectionId} = ? AND ${VerseEntry.prompt} = ?',
      whereArgs: [collectionId, prompt],
    );
    return results.isNotEmpty;
  }

  @override
  Future<int> numberInCollection(String collectionId) async {
    final List<Map<String, dynamic>> result = await _database.rawQuery('''
      SELECT COUNT(*)
      FROM ${VerseEntry.verseTable}
      WHERE ${VerseEntry.collectionId} = ?
    ''', [collectionId]);

    return result.isNotEmpty ? result.first.values.first : 0;
  }

  Future<void> close() async => _database.close();

  @override
  Future<List<Map<String, Object?>>> dumpCollections([
    String? collectionId,
  ]) async {
    if (collectionId == null) {
      return await _database.query(CollectionEntry.collectionTable);
    }
    return await _database.query(
      CollectionEntry.collectionTable,
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
  }

  @override
  Future<List<Map<String, Object?>>> dumpVerses([
    String? collectionId,
  ]) async {
    if (collectionId == null) {
      return await _database.query(VerseEntry.verseTable);
    }
    return await _database.query(
      VerseEntry.verseTable,
      columns: [
        VerseEntry.id,
        VerseEntry.collectionId,
        VerseEntry.prompt,
        VerseEntry.verseText,
      ],
      where: '${VerseEntry.collectionId} = ?',
      whereArgs: [collectionId],
    );
  }

  @override
  Future<int> restoreCollections(
    List<Map<String, Object?>> collections,
  ) async {
    int collectionAddedCount = 0;
    for (final collection in collections) {
      final id = collection[CollectionEntry.id] as String;
      var name = collection[CollectionEntry.name] as String;
      final date = collection[CollectionEntry.accessedDate] as int;

      // if collection id exists do nothing
      if (await _collectionExists(id)) continue;

      // add another entry for a duplicate collection name
      if (await _collectionNameExists(name)) {
        name = '$name (backup)';
      }

      // insert the new collection
      await _database.insert(
        CollectionEntry.collectionTable,
        {
          CollectionEntry.id: id,
          CollectionEntry.name: name,
          CollectionEntry.accessedDate: date,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      collectionAddedCount++;
    }
    return collectionAddedCount;
  }

  Future<bool> _collectionExists(String collectionId) async {
    final result = await _database.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM ${CollectionEntry.collectionTable} '
      'WHERE ${CollectionEntry.id}=?)',
      [collectionId],
    );
    return (Sqflite.firstIntValue(result) == 1);
  }

  Future<bool> _collectionNameExists(String name) async {
    final result = await _database.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM ${CollectionEntry.collectionTable} '
      'WHERE ${CollectionEntry.name}=?)',
      [name],
    );
    return (Sqflite.firstIntValue(result) == 1);
  }

  @override
  Future<(int added, int updated, int errorCount)> restoreVerses(
      List<Map<String, Object?>> verses) async {
    int addedCount = 0;
    int updatedCount = 0;
    int errorCount = 0;

    for (final verse in verses) {
      try {
        final id = verse[VerseEntry.id] as String;
        final collectionId = verse[VerseEntry.collectionId] as String;
        final prompt = verse[VerseEntry.prompt] as String;
        final verseText = verse[VerseEntry.verseText] as String;
        final modifiedDate = verse[VerseEntry.modifiedDate] as int?;
        final dueDate = verse[VerseEntry.nextDueDate] as int?;
        final interval = (verse[VerseEntry.interval] as int?) ?? 0;

        // check if verse exists
        final currentModified = await _existingVerseModifiedDate(id);
        if (currentModified == null) {
          // if it doesn't exist then insert it
          await _insertVerse(
            id: id,
            collectionId: collectionId,
            prompt: prompt,
            verseText: verseText,
            modifiedDate: modifiedDate ?? _timestampNow(),
            dueDate: dueDate,
            interval: interval,
          );
          addedCount++;
        } else {
          // don't bother updating current if backup doesn't have modified date.
          if (modifiedDate == null) continue;
          // if current is newer or same then ignore backup
          if (currentModified >= modifiedDate) continue;
          // otherwise update it
          await _updateVerse(
            id: id,
            collectionId: collectionId,
            prompt: prompt,
            verseText: verseText,
            modifiedDate: modifiedDate,
            dueDate: dueDate,
            interval: interval,
          );
          updatedCount++;
        }
      } catch (error) {
        // ignore formatting errors with single verses
        errorCount++;
      }
    }
    return (addedCount, updatedCount, errorCount);
  }

  Future<int?> _existingVerseModifiedDate(String verseId) async {
    final result = await _database.query(
      VerseEntry.verseTable,
      columns: [VerseEntry.modifiedDate],
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
    if (result.isEmpty) return null;
    return result.first[VerseEntry.modifiedDate] as int;
  }

  Future<void> _updateVerse({
    required String id,
    required String collectionId,
    required String prompt,
    required String verseText,
    required int modifiedDate,
    required int? dueDate,
    required int interval,
  }) async {
    await _database.update(
      VerseEntry.verseTable,
      {
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: prompt,
        VerseEntry.verseText: verseText,
        VerseEntry.modifiedDate: modifiedDate,
        VerseEntry.nextDueDate: dueDate,
        VerseEntry.interval: interval,
      },
      where: '${VerseEntry.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> _insertVerse({
    required String id,
    required String collectionId,
    required String prompt,
    required String verseText,
    required int modifiedDate,
    required int? dueDate,
    required int interval,
  }) async {
    await _database.insert(
      VerseEntry.verseTable,
      {
        VerseEntry.id: id,
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: prompt,
        VerseEntry.verseText: verseText,
        VerseEntry.modifiedDate: modifiedDate,
        VerseEntry.nextDueDate: dueDate,
        VerseEntry.interval: interval,
      },
    );
  }

  @override
  Future<int> resetDueDates({required String collectionId}) async {
    final now = _timestampNow();
    return await _database.update(
      VerseEntry.verseTable,
      {
        VerseEntry.modifiedDate: now,
        VerseEntry.nextDueDate: null,
        VerseEntry.interval: 0,
      },
      where: '${VerseEntry.collectionId} = ?',
      whereArgs: [collectionId],
    );
  }
}
