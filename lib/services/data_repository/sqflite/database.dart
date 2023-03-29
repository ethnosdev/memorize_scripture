import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalStorage implements DataRepository {
  static const String _databaseName = "my_database.db";
  static const int _databaseVersion = 1;
  late Database _database;

  @override
  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        await db.execute(CollectionEntry.createCollectionTable);
        await db.execute(VerseEntry.createVocabTable);
      },
      version: _databaseVersion,
    );
  }

  @override
  Future<List<Collection>> fetchCollections() async {
    final List<Map<String, dynamic>> collectionMaps =
        await _database.query(CollectionEntry.collectionTable);
    return List.generate(collectionMaps.length, (i) {
      return Collection(
        id: collectionMaps[i][CollectionEntry.id],
        name: collectionMaps[i][CollectionEntry.name],
      );
    });
  }

  @override
  Future<List<Verse>> fetchAllVerses([String? collectionId]) async {
    List<Map<String, dynamic>> verseMaps;
    if (collectionId != null) {
      verseMaps = await _database.query(
        VerseEntry.verseTable,
        where: '${VerseEntry.collectionId} = ?',
        whereArgs: [collectionId],
      );
    } else {
      verseMaps = await _database.query(VerseEntry.verseTable);
    }

    return List.generate(verseMaps.length, (i) {
      return Verse(
        id: verseMaps[i][VerseEntry.id],
        prompt: verseMaps[i][VerseEntry.prompt],
        answer: verseMaps[i][VerseEntry.answer],
        nextDueDate: verseMaps[i][VerseEntry.nextDueDate],
        consecutiveCorrect: verseMaps[i][VerseEntry.consecutiveCorrect],
        easinessFactor: verseMaps[i][VerseEntry.easinessFactor],
      );
    });
  }

  @override
  Future<List<Verse>> fetchTodaysVerses(
      {String? collectionId, int? limit}) async {
    final int today = DateTime.now().millisecondsSinceEpoch;
    List<Map<String, dynamic>> verseMaps;

    if (collectionId != null) {
      verseMaps = await _database.query(
        VerseEntry.verseTable,
        where:
            '${VerseEntry.collectionId} = ? AND ${VerseEntry.nextDueDate} <= ?',
        whereArgs: [collectionId, today],
        orderBy: '${VerseEntry.nextDueDate} ASC',
        limit: limit,
      );
    } else {
      verseMaps = await _database.query(
        VerseEntry.verseTable,
        where: '${VerseEntry.nextDueDate} <= ?',
        whereArgs: [today],
        orderBy: '${VerseEntry.nextDueDate} ASC',
        limit: limit,
      );
    }

    return List.generate(verseMaps.length, (i) {
      return Verse(
        id: verseMaps[i][VerseEntry.id],
        prompt: verseMaps[i][VerseEntry.prompt],
        answer: verseMaps[i][VerseEntry.answer],
        nextDueDate: verseMaps[i][VerseEntry.nextDueDate],
        consecutiveCorrect: verseMaps[i][VerseEntry.consecutiveCorrect],
        easinessFactor: verseMaps[i][VerseEntry.easinessFactor],
      );
    });
  }

  @override
  Future<Verse?> fetchVerse({required String verseId}) async {
    final List<Map<String, dynamic>> verseMaps = await _database.query(
      VerseEntry.verseTable,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );

    if (verseMaps.isNotEmpty) {
      return Verse(
        id: verseMaps[0][VerseEntry.id],
        prompt: verseMaps[0][VerseEntry.prompt],
        answer: verseMaps[0][VerseEntry.answer],
        nextDueDate: verseMaps[0][VerseEntry.nextDueDate],
        consecutiveCorrect: verseMaps[0][VerseEntry.consecutiveCorrect],
        easinessFactor: verseMaps[0][VerseEntry.easinessFactor],
      );
    } else {
      return null;
    }
  }

  @override
  Future<void> upsertVerse(String collectionId, Verse verse) async {
    if (verse.id == null) {
      final List<Map<String, dynamic>> existingVerseMaps =
          await _database.query(
        VerseEntry.verseTable,
        where: '${VerseEntry.prompt} = ? AND ${VerseEntry.collectionId} = ?',
        whereArgs: [verse.prompt, collectionId],
      );

      if (existingVerseMaps.isEmpty) {
        await _database.insert(
          VerseEntry.verseTable,
          {
            VerseEntry.id: Uuid().v4(),
            VerseEntry.collectionId: collectionId,
            VerseEntry.prompt: verse.prompt,
            VerseEntry.answer: verse.answer,
            VerseEntry.nextDueDate: verse.nextDueDate,
            VerseEntry.consecutiveCorrect: verse.consecutiveCorrect,
            VerseEntry.easinessFactor: verse.easinessFactor,
          },
        );
      }
    } else {
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
  }

  @override
  Future<void> batchInsertVerses({
    required Collection collection,
    required List<Verse> verses,
  }) async {
    final Batch batch = _database.batch();

    for (Verse verse in verses) {
      if (verse.id == null) {
        batch.insert(
          VerseEntry.verseTable,
          {
            VerseEntry.id: Uuid().v4(),
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
    await _database.delete(
      VerseEntry.verseTable,
      where: '${VerseEntry.id} = ?',
      whereArgs: [verseId],
    );
  }

  @override
  Future<void> upsertCollection(Collection collection) async {
    if (collection.id == null) {
      final List<Map<String, dynamic>> existingCollectionMaps =
          await _database.query(
        CollectionEntry.collectionTable,
        where: '${CollectionEntry.name} = ?',
        whereArgs: [collection.name],
      );

      if (existingCollectionMaps.isEmpty) {
        await _database.insert(
          CollectionEntry.collectionTable,
          {
            CollectionEntry.id: Uuid().v4(),
            CollectionEntry.name: collection.name,
          },
        );
      }
    } else {
      await _database.update(
        CollectionEntry.collectionTable,
        {
          CollectionEntry.name: collection.name,
        },
        where: '${CollectionEntry.id} = ?',
        whereArgs: [collection.id],
      );
    }
  }

  @override
  Future<void> deleteCollection({required String collectionId}) async {
    await _database.delete(
      CollectionEntry.collectionTable,
      where: '${CollectionEntry.id} = ?',
      whereArgs: [collectionId],
    );
  }
}

// class LocalStorage implements DataRepository {
//   static const _databaseName = 'verses.db';
//   Database? _db;

//   @override
//   Future<void> init() async {
//     _db = await openDatabase(
//       join(await getDatabasesPath(), _databaseName),
//       onCreate: (db, version) {
//         db.execute(CollectionEntry.createCollectionTable);
//         db.execute(VerseEntry.createVocabTable);
//       },
//       version: 1,
//     );
//   }

//   @override
//   Future<List<Collection>> fetchCollections() async {
//     final List<Map<String, dynamic>> maps =
//         await _db!.query('collections', columns: ['id', 'name']);
//     return List.generate(maps.length, (i) {
//       return Collection(
//         id: maps[i]['id'],
//         name: maps[i]['name'],
//       );
//     });
//   }

//   @override
//   Future<List<Verse>> fetchAllVerses(String collectionId) async {
//     final List<Map<String, dynamic>> maps = await _db!.query('verses',
//         columns: ['id', 'prompt', 'answer'],
//         where: 'collection_id = ?',
//         whereArgs: [collectionId]);
//     return List.generate(maps.length, (i) {
//       return Verse(
//         id: maps[i]['id'],
//         prompt: maps[i]['prompt'],
//         answer: maps[i]['answer'],
//       );
//     });
//   }

//   @override
//   Future<Verse?> fetchVerse({
//     required String collectionId,
//     required String verseId,
//   }) async {
//     final List<Map<String, dynamic>> maps = await _db!.query('verses',
//         columns: ['id', 'prompt', 'answer'],
//         where: 'collection_id = ? AND id = ?',
//         whereArgs: [collectionId, verseId]);
//     if (maps.isNotEmpty) {
//       return Verse(
//         id: maps[0]['id'],
//         prompt: maps[0]['prompt'],
//         answer: maps[0]['answer'],
//       );
//     } else {
//       return null;
//     }
//   }

//   @override
//   Future<void> upsertVerse(String collectionId, Verse verse) async {
//     await _db!.insert(
//       'verses',
//       {
//         'id': verse.id,
//         'collection_id': collectionId,
//         'prompt': verse.prompt,
//         'answer': verse.answer,
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   @override
//   Future<void> batchInsertVerses(Collection collection) async {
//     final batch = _db!.batch();
//     for (Verse verse in collection.verses!) {
//       batch.insert(
//         'verses',
//         {
//           'id': verse.id,
//           'collection_id': collection.id,
//           'prompt': verse.prompt,
//           'answer': verse.answer,
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }
//     await batch.commit();
//   }
// }

class VerseEntry {
  // Vocab table
  static const String verseTable = "verses";

  // Column names
  static const String id = "_id";
  static const String collectionId = "collection_id";
  static const String prompt = "prompt";
  static const String answer = "answer";
  static const String nextDueDate = "next_due_date";
  static const String consecutiveCorrect = "consecutive_correct";
  static const String easinessFactor = "easiness_factor";
  static const String dateAccessed = "date_accessed";

  // SQL statements
  static const String createVocabTable = '''
CREATE TABLE $verseTable (
  $id TEXT PRIMARY KEY,
  $collectionId TEXT NOT NULL,
  $prompt TEXT,
  $answer TEXT,
  $nextDueDate INTEGER DEFAULT 0,
  $consecutiveCorrect INTEGER DEFAULT 0,
  $easinessFactor REAL DEFAULT 2.5,
  $dateAccessed TEXT NOT NULL,
  FOREIGN KEY($collectionId) 
  REFERENCES ${CollectionEntry.collectionTable} (${CollectionEntry.id}))
''';
}

class CollectionEntry {
  // List table
  static const String collectionTable = "collection";

  // Column names
  static const String id = "_id";
  static const String name = "name";

  // SQL statements
  static const String createCollectionTable = '''
CREATE TABLE $collectionTable (
  $id TEXT PRIMARY KEY,
  $name TEXT NOT NULL UNIQUE)
''';
}
