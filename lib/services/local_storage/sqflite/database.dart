import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/local_storage/sqflite/schema.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// This affects both the schema in this file and also the backup/restore
// features of the app.
const databaseVersion = 3;

class SqfliteStorage implements LocalStorage {
  final String _databaseName = "database.db";
  late Database _database;

  @override
  Future<void> init() async {
    final path = join(await getDatabasesPath(), _databaseName);
    debugPrint('init: $path');
    _database = await openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: databaseVersion,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(CollectionEntry.createTable);
    await db.execute(VerseEntry.createTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('upgrading database version from $oldVersion to $newVersion');
    if (oldVersion < 2) {
      await _upgradeFrom1to2(db);
    }
    if (oldVersion < 3) {
      await _upgradeFrom2to3(db);
    }
  }

  Future<void> _upgradeFrom1to2(Database db) async {
    await db.execute('ALTER TABLE verses ADD COLUMN hint TEXT');
  }

  Future<void> _upgradeFrom2to3(Database db) async {
    // rename access_date to modified_date in collection table
    await db.execute('ALTER TABLE collection ADD COLUMN modified_date INTEGER');
    await db.execute('UPDATE collection SET modified_date = access_date');

    // The following line was in version 2.0.0 but SQLite apparently doesn't
    // support dropping columns so we will remove this line and just ignore
    // it in the database from here on out.
    // await db.execute('ALTER TABLE collection DROP COLUMN access_date');

    // add created_date to verses and collection tables
    await db.execute(
        'ALTER TABLE verses ADD COLUMN created_date INTEGER DEFAULT 0');
    await db.execute(
        'ALTER TABLE collection ADD COLUMN created_date INTEGER DEFAULT 0');
  }

  @override
  Future<List<Collection>> fetchCollections() async {
    final collections = await _database.query(
      CollectionEntry.tableName,
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
        VerseEntry.tableName,
        where: '${VerseEntry.collectionId} = ?',
        whereArgs: [collectionId],
      );
    } else {
      verses = await _database.query(VerseEntry.tableName);
    }
    return List.generate(verses.length, (i) {
      final verse = verses[i];
      return Verse(
        id: verse[VerseEntry.id] as String,
        prompt: verse[VerseEntry.prompt] as String,
        text: verse[VerseEntry.verseText] as String,
        hint: (verse[VerseEntry.hint] as String?) ?? '',
        nextDueDate: _dbVerseToDate(verse),
        interval: _dbVerseToInterval(verse),
      );
    });
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
    final verses = [...newVerses, ...reviewVerses];
    return List.generate(verses.length, (i) {
      final verse = verses[i];
      return Verse(
        id: verse[VerseEntry.id] as String,
        prompt: verse[VerseEntry.prompt] as String,
        text: verse[VerseEntry.verseText] as String,
        hint: (verse[VerseEntry.hint] as String?) ?? '',
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
      VerseEntry.tableName,
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
      VerseEntry.tableName,
      where: '${VerseEntry.collectionId} = ? '
          'AND ${VerseEntry.nextDueDate} <= ?',
      whereArgs: [collectionId, today],
      orderBy: '${VerseEntry.prompt} ASC',
    );
  }

  @override
  Future<Verse?> fetchVerse({required String verseId}) async {
    final results = await _database.query(
      VerseEntry.tableName,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
    if (results.isEmpty) return null;
    final verse = results.first;
    return Verse(
      id: verse[VerseEntry.id] as String,
      prompt: verse[VerseEntry.prompt] as String,
      text: verse[VerseEntry.verseText] as String,
      hint: (verse[VerseEntry.hint] as String?) ?? '',
      nextDueDate: _dbVerseToDate(verse),
      interval: _dbVerseToInterval(verse),
    );
  }

  @override
  Future<void> insertVerse(String collectionId, Verse verse) async {
    await _database.insert(
      VerseEntry.tableName,
      {
        VerseEntry.id: verse.id,
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.verseText: verse.text,
        VerseEntry.hint: verse.hint,
        VerseEntry.createdDate: _timestampNow(),
        VerseEntry.modifiedDate: _timestampNow(),
        VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
        VerseEntry.interval: verse.interval.inDays,
      },
    );
    await getIt<UserSettings>().setLastLocalUpdate();
  }

  @override
  Future<void> updateVerse(String collectionId, Verse verse) async {
    await _database.update(
      VerseEntry.tableName,
      {
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.verseText: verse.text,
        VerseEntry.hint: verse.hint,
        VerseEntry.modifiedDate: _timestampNow(),
        VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
        VerseEntry.interval: verse.interval.inDays,
      },
      where: '${VerseEntry.id} = ?',
      whereArgs: [verse.id],
    );
    await getIt<UserSettings>().setLastLocalUpdate();
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
        VerseEntry.tableName,
        {
          VerseEntry.id: verse.id,
          VerseEntry.collectionId: collection.id,
          VerseEntry.prompt: verse.prompt,
          VerseEntry.verseText: verse.text,
          VerseEntry.hint: verse.hint,
          VerseEntry.createdDate: timestamp,
          VerseEntry.modifiedDate: timestamp,
          VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
          VerseEntry.interval: verse.interval.inDays,
        },
      );
    }

    await batch.commit(noResult: true);
    await getIt<UserSettings>().setLastLocalUpdate();
  }

  @override
  Future<void> deleteVerse({required String verseId}) async {
    await _database.delete(
      VerseEntry.tableName,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
    // Note: not setting lastLocalUpdate but if we start tracking deletes
    // in the future, then we should set it also.
  }

  @override
  Future<void> insertCollection(Collection collection) async {
    await _upsertCollection(collection);
    await getIt<UserSettings>().setLastLocalUpdate();
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    await _upsertCollection(collection);
    await getIt<UserSettings>().setLastLocalUpdate();
  }

  Future<void> _upsertCollection(Collection collection) async {
    // Check if another collection has the same name
    final results = await _database.query(
      CollectionEntry.tableName,
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
      CollectionEntry.tableName,
      {
        CollectionEntry.id: collection.id,
        CollectionEntry.name: collection.name.trim(),
        // TODO: handle creation date
        CollectionEntry.modifiedDate: _timestampNow(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCollection({required String collectionId}) async {
    await _database.delete(
      CollectionEntry.tableName,
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
    await _database.delete(
      VerseEntry.tableName,
      where: '${VerseEntry.collectionId} = ?',
      whereArgs: [collectionId],
    );
    // Note: not setting lastLocalUpdate but if we start tracking deletes
    // in the future, then we should set it also.
  }

  @override
  Future<bool> promptExists({
    required String collectionId,
    required String prompt,
  }) async {
    final results = await _database.query(
      VerseEntry.tableName,
      where: '${VerseEntry.collectionId} = ? AND ${VerseEntry.prompt} = ?',
      whereArgs: [collectionId, prompt],
    );
    return results.isNotEmpty;
  }

  @override
  Future<int> numberInCollection(String collectionId) async {
    final List<Map<String, dynamic>> result = await _database.rawQuery('''
      SELECT COUNT(*)
      FROM ${VerseEntry.tableName}
      WHERE ${VerseEntry.collectionId} = ?
    ''', [collectionId]);

    return result.isNotEmpty ? result.first.values.first : 0;
  }

  Future<void> close() async => _database.close();

  @override
  Future<String> backupCollections() async {
    final collections = await _database.query(CollectionEntry.tableName);
    var verses = await _database.query(VerseEntry.tableName);
    return await _encodeBackup(collections, verses);
  }

  Future<String> _encodeBackup(
    List<Map<String, Object?>> collections,
    List<Map<String, Object?>> verses,
  ) {
    final backup = {
      'date': _dateToSecondsSinceEpoch(DateTime.now()),
      'version': databaseVersion,
      'collections': collections,
      'verses': verses,
    };
    const encoder = JsonEncoder.withIndent('  ');
    return compute(encoder.convert, backup);
  }

  @override
  Future<String> getSharedCollection(String collectionId) async {
    final collection = await _database.query(
      CollectionEntry.tableName,
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
    // For the purposes or sharing, not all columns are needed.
    final verse = await _database.query(
      VerseEntry.tableName,
      columns: [
        VerseEntry.id,
        VerseEntry.collectionId,
        VerseEntry.prompt,
        VerseEntry.verseText,
        VerseEntry.hint,
      ],
      where: '${VerseEntry.collectionId} = ?',
      whereArgs: [collectionId],
    );
    return await _encodeBackup(collection, verse);
  }

  @override
  Future<(int added, int updated, int errors)> restoreBackup(String json,
      {String? timestamp}) async {
    final jsonMap = await compute(jsonDecode, json);
    final collections =
        (jsonMap['collections'] as List).cast<Map<String, Object?>>();
    final verses = (jsonMap['verses'] as List).cast<Map<String, Object?>>();
    await _restoreCollections(collections);
    final counts = await _restoreVerses(verses);
    await getIt<UserSettings>().setLastLocalUpdate(timestamp);
    return counts;
  }

  Future<int> _restoreCollections(
    List<Map<String, Object?>> collections,
  ) async {
    int collectionAddedUpdatedCount = 0;
    for (final collection in collections) {
      try {
        final id = collection[CollectionEntry.id] as String;
        var name = collection[CollectionEntry.name] as String;
        final modifiedDate = collection[CollectionEntry.modifiedDate] as int?;
        final createdDate = collection[CollectionEntry.createdDate] as int?;

        // if collection id exists do nothing
        if (await _collectionExists(id)) {
          // don't bother updating current if backup doesn't have modified date.
          if (modifiedDate == null) continue;
          // if current is newer or same then ignore backup
          final currentModified = await _collectionModifiedDate(id);
          if (currentModified != null && currentModified >= modifiedDate) {
            continue;
          }
        }

        // add another entry for a duplicate collection name
        if (await _collectionNameExists(name)) {
          name = '$name (backup)';
        }

        // insert/update the new collection
        await _database.insert(
          CollectionEntry.tableName,
          {
            CollectionEntry.id: id,
            CollectionEntry.name: name,
            CollectionEntry.createdDate: createdDate ?? 0,
            CollectionEntry.modifiedDate: modifiedDate ?? _timestampNow(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        collectionAddedUpdatedCount++;
      } catch (e) {
        // discard errors
      }
    }
    return collectionAddedUpdatedCount;
  }

  Future<bool> _collectionExists(String collectionId) async {
    final result = await _database.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM ${CollectionEntry.tableName} '
      'WHERE ${CollectionEntry.id}=?)',
      [collectionId],
    );
    return (Sqflite.firstIntValue(result) == 1);
  }

  Future<int?> _collectionModifiedDate(String collectionId) async {
    final result = await _database.query(
      CollectionEntry.tableName,
      columns: [CollectionEntry.modifiedDate],
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
    if (result.isEmpty) return null;
    return result.first[CollectionEntry.modifiedDate] as int?;
  }

  Future<bool> _collectionNameExists(String name) async {
    final result = await _database.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM ${CollectionEntry.tableName} '
      'WHERE ${CollectionEntry.name}=?)',
      [name],
    );
    return (Sqflite.firstIntValue(result) == 1);
  }

  Future<(int added, int updated, int errorCount)> _restoreVerses(
    List<Map<String, Object?>> verses,
  ) async {
    int addedCount = 0;
    int updatedCount = 0;
    int errorCount = 0;

    for (final verse in verses) {
      try {
        final id = verse[VerseEntry.id] as String;
        final collectionId = verse[VerseEntry.collectionId] as String;
        final prompt = verse[VerseEntry.prompt] as String;
        final verseText = verse[VerseEntry.verseText] as String;
        final hint = (verse[VerseEntry.hint] as String?) ?? '';
        final createdDate = verse[VerseEntry.createdDate] as int?;
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
            hint: hint,
            createdDate: createdDate ?? 0,
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
            hint: hint,
            createdDate: createdDate ?? 0,
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
      VerseEntry.tableName,
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
    required String hint,
    required int createdDate,
    required int modifiedDate,
    required int? dueDate,
    required int interval,
  }) async {
    await _database.update(
      VerseEntry.tableName,
      {
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: prompt,
        VerseEntry.verseText: verseText,
        VerseEntry.hint: hint,
        VerseEntry.createdDate: createdDate,
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
    required String hint,
    required int createdDate,
    required int modifiedDate,
    required int? dueDate,
    required int interval,
  }) async {
    await _database.insert(
      VerseEntry.tableName,
      {
        VerseEntry.id: id,
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: prompt,
        VerseEntry.verseText: verseText,
        VerseEntry.hint: hint,
        VerseEntry.createdDate: createdDate,
        VerseEntry.modifiedDate: modifiedDate,
        VerseEntry.nextDueDate: dueDate,
        VerseEntry.interval: interval,
      },
    );
  }

  @override
  Future<int> resetDueDates({required String collectionId}) async {
    final now = _timestampNow();
    final numberAffected = await _database.update(
      VerseEntry.tableName,
      {
        VerseEntry.modifiedDate: now,
        VerseEntry.nextDueDate: null,
        VerseEntry.interval: 0,
      },
      where: '${VerseEntry.collectionId} = ?',
      whereArgs: [collectionId],
    );
    await getIt<UserSettings>().setLastLocalUpdate();
    return numberAffected;
  }
}
