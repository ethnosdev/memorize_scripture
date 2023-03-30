import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/data_repository/sqflite/schema.dart';
import 'package:memorize_scripture/services/sample_verses.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalStorage implements DataRepository {
  static const String _databaseName = "database.db";
  static const int _databaseVersion = 1;
  late Database _database;

  @override
  Future<void> init() async {
    final path = join(await getDatabasesPath(), _databaseName);
    print('init: $path');
    _database = await openDatabase(
      path,
      onCreate: (db, version) async {
        print('creating database: ${db.path}');
        await db.execute(CollectionEntry.createCollectionTable);
        await db.execute(VerseEntry.createVocabTable);
        await _insertInitialData(db);
        print('finished creating');
      },
      version: _databaseVersion,
    );
  }

  Future<void> _insertInitialData(Database db) async {
    final collection = Collection(
      id: const Uuid().v4(),
      name: 'Starter pack',
    );
    await db.insert(CollectionEntry.collectionTable, {
      CollectionEntry.id: collection.id,
      CollectionEntry.name: collection.name,
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
    print('collectionId: $collectionId');
    return List.generate(verses.length, (i) {
      return Verse(
        id: verses[i][VerseEntry.id] as String,
        prompt: verses[i][VerseEntry.prompt] as String,
        answer: verses[i][VerseEntry.answer] as String,
        nextDueDate: verses[i][VerseEntry.nextDueDate] as int,
        consecutiveCorrect: verses[i][VerseEntry.consecutiveCorrect] as int,
        easinessFactor: verses[i][VerseEntry.easinessFactor] as double,
      );
    });
  }

  @override
  Future<List<Verse>> fetchTodaysVerses(
      {String? collectionId, int? limit}) async {
    final int today = DateTime.now().millisecondsSinceEpoch;
    List<Map<String, Object?>> verses;

    if (collectionId != null) {
      verses = await _database.query(
        VerseEntry.verseTable,
        where:
            '${VerseEntry.collectionId} = ? AND ${VerseEntry.nextDueDate} <= ?',
        whereArgs: [collectionId, today],
        orderBy: '${VerseEntry.nextDueDate} ASC',
        limit: limit,
      );
    } else {
      verses = await _database.query(
        VerseEntry.verseTable,
        where: '${VerseEntry.nextDueDate} <= ?',
        whereArgs: [today],
        orderBy: '${VerseEntry.nextDueDate} ASC',
        limit: limit,
      );
    }
    print('fetchTodaysVerses: $verses');
    return List.generate(verses.length, (i) {
      return Verse(
        id: verses[i][VerseEntry.id] as String,
        prompt: verses[i][VerseEntry.prompt] as String,
        answer: verses[i][VerseEntry.answer] as String,
        nextDueDate: verses[i][VerseEntry.nextDueDate] as int,
        consecutiveCorrect: verses[i][VerseEntry.consecutiveCorrect] as int,
        easinessFactor: verses[i][VerseEntry.easinessFactor] as double,
      );
    });
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
      nextDueDate: verse[VerseEntry.nextDueDate] as int,
      consecutiveCorrect: verse[VerseEntry.consecutiveCorrect] as int,
      easinessFactor: verse[VerseEntry.easinessFactor] as double,
    );
  }

  @override
  Future<void> upsertVerse(String collectionId, Verse verse) async {
    if (verse.id == null) {
      // TODO: catch cases when there is a unique constraint conflict
      // for the prompt (ie, adding a new verse with the same prompt
      // as another)
      await _insert(collectionId, verse);
    } else {
      await _update(collectionId, verse);
    }
  }

  Future<void> _insert(String collectionId, Verse verse) async {
    print('_insert verse');
    await _database.insert(
      VerseEntry.verseTable,
      {
        VerseEntry.id: const Uuid().v4(),
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.answer: verse.answer,
        VerseEntry.nextDueDate: verse.nextDueDate,
        VerseEntry.consecutiveCorrect: verse.consecutiveCorrect,
        VerseEntry.easinessFactor: verse.easinessFactor,
      },
    );
  }

  Future<void> _update(String collectionId, Verse verse) async {
    print('_update verse');
    await _database.update(
      VerseEntry.verseTable,
      {
        VerseEntry.collectionId: collectionId,
        VerseEntry.prompt: verse.prompt,
        VerseEntry.answer: verse.answer,
        VerseEntry.nextDueDate: verse.nextDueDate,
        VerseEntry.consecutiveCorrect: verse.consecutiveCorrect,
        VerseEntry.easinessFactor: verse.easinessFactor,
      },
      where: '${VerseEntry.id} = ?',
      whereArgs: [verse.id],
    );
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
    for (Verse verse in verses) {
      if (verse.id == null) {
        batch.insert(
          VerseEntry.verseTable,
          {
            VerseEntry.id: const Uuid().v4(),
            VerseEntry.collectionId: collection.id,
            VerseEntry.prompt: verse.prompt,
            VerseEntry.answer: verse.answer,
            VerseEntry.nextDueDate: verse.nextDueDate,
            VerseEntry.consecutiveCorrect: verse.consecutiveCorrect,
            VerseEntry.easinessFactor: verse.easinessFactor,
          },
        );
      } else {
        batch.update(
          VerseEntry.verseTable,
          {
            VerseEntry.collectionId: collection.id,
            VerseEntry.prompt: verse.prompt,
            VerseEntry.answer: verse.answer,
            VerseEntry.nextDueDate: verse.nextDueDate,
            VerseEntry.consecutiveCorrect: verse.consecutiveCorrect,
            VerseEntry.easinessFactor: verse.easinessFactor,
          },
          where: '${VerseEntry.id} = ?',
          whereArgs: [verse.id],
        );
      }
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
  Future<void> upsertCollection(Collection collection) async {
    print('upsertCollection');

    // Check if another collection has the same name
    final results = await _database.query(
      CollectionEntry.collectionTable,
      where: '${CollectionEntry.name} = ?',
      whereArgs: [collection.name.trim()],
    );
    if (results.isNotEmpty &&
        results.first[CollectionEntry.id] != collection.id) {
      // Don't allow duplicate collection names
      print('Dont allow duplicate collection names');
      return;
    }

    print('id: ${collection.id}, name: ${collection.name}');

    // Insert or replace the collection
    await _database.insert(
      CollectionEntry.collectionTable,
      {
        CollectionEntry.id: collection.id ?? const Uuid().v4(),
        CollectionEntry.name: collection.name.trim(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCollection({required String collectionId}) async {
    print('deleteCollection');
    await _database.delete(
      CollectionEntry.collectionTable,
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
  }
}
