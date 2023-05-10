import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/data_repository/sqflite/schema.dart';
import 'package:memorize_scripture/services/sample_verses.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalStorage implements DataRepository {
  final String _databaseName = "database.db";
  static const int _databaseVersion = 1;
  late Database _database;
  final bool isTesting;

  LocalStorage({this.isTesting = false});

  @override
  Future<void> init() async {
    final path = (isTesting)
        ? inMemoryDatabasePath
        : join(await getDatabasesPath(), _databaseName);
    print('init: $path');
    _database = await openDatabase(
      path,
      onCreate: _onCreate,
      version: _databaseVersion,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('creating database: ${db.path}');
    await db.execute(CollectionEntry.createCollectionTable);
    await db.execute(VerseEntry.createVocabTable);
    await _insertInitialData(db);
    print('finished creating');
  }

  Future<void> _insertInitialData(Database db) async {
    final collection = Collection(
      id: const Uuid().v4(),
      name: 'Starter pack',
    );
    final timestamp = _timestampNow();
    await db.insert(CollectionEntry.collectionTable, {
      CollectionEntry.id: collection.id,
      CollectionEntry.name: collection.name,
      CollectionEntry.accessedDate: timestamp,
    });
    await batchInsertVerses(
      database: db,
      collection: collection,
      verses: starterVersesWeb,
    );
  }

  @override
  Future<List<Collection>> fetchCollections() async {
    final collections = await _database.query(
      CollectionEntry.collectionTable,
      orderBy: 'LOWER(${CollectionEntry.name}) ASC',
    );
    print('fetchCollections: $collections');
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
    print('fetchAllVerses: ${verses.length}');
    return List.generate(verses.length, (i) {
      final verse = verses[i];
      return Verse(
        id: verse[VerseEntry.id] as String,
        prompt: verse[VerseEntry.prompt] as String,
        answer: verse[VerseEntry.answer] as String,
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
    print('collectionId: $collectionId');
    print('_fetchNewVerses: $newVerses');
    print('_fetchReviewVerses: $reviewVerses');
    final verses = [...newVerses, ...reviewVerses];
    return List.generate(verses.length, (i) {
      final verse = verses[i];
      return Verse(
        id: verse[VerseEntry.id] as String,
        prompt: verse[VerseEntry.prompt] as String,
        answer: verse[VerseEntry.answer] as String,
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
      orderBy: '${VerseEntry.nextDueDate} ASC',
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
    print('fetchVerse: $verse');
    return Verse(
      id: verse[VerseEntry.id] as String,
      prompt: verse[VerseEntry.prompt] as String,
      answer: verse[VerseEntry.answer] as String,
      nextDueDate: _dbVerseToDate(verse),
      interval: _dbVerseToInterval(verse),
    );
  }

  @override
  Future<void> insertVerse(String collectionId, Verse verse) async {
    print('insert verse');
    await _database.insert(
      VerseEntry.verseTable,
      {
        VerseEntry.id: verse.id,
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.answer: verse.answer,
        VerseEntry.modifiedDate: _timestampNow(),
        VerseEntry.nextDueDate: _dateToSecondsSinceEpoch(verse.nextDueDate),
        VerseEntry.interval: verse.interval.inDays,
      },
    );
  }

  @override
  Future<void> updateVerse(String collectionId, Verse verse) async {
    print('update verse');
    await _database.update(
      VerseEntry.verseTable,
      {
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.answer: verse.answer,
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
    print('batchInsertVerses');
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
          VerseEntry.answer: verse.answer,
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
    print('deleteVerse');
    await _database.delete(
      VerseEntry.verseTable,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
  }

  @override
  Future<void> insertCollection(Collection collection) async {
    print('insertCollection');
    await _upsertCollection(collection);
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    print('updateCollection');
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
      // Don't allow duplicate collection names
      print('Don\'t allow duplicate collection names');
      return;
    }

    print('id: ${collection.id}, name: ${collection.name}');

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
    print('promptExists: $prompt');
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
}
