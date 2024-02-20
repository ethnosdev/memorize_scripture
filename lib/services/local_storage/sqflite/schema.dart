class VerseEntry {
  // Vocab table
  static const String tableName = "verses";

  // Column names
  static const String id = '_id';
  static const String collectionId = 'collection_id';
  static const String prompt = 'prompt';
  static const String verseText = 'answer';
  static const String hint = 'hint';
  // seconds since epoch, new verses default to null
  static const String modifiedDate = 'modified_date';
  static const String nextDueDate = 'next_due_date';
  // interval in days
  static const String interval = 'interval';
  static const String synced = 'synced';

  // SQL statements
  static const String createTable = '''
  CREATE TABLE $tableName (
    $id TEXT PRIMARY KEY,
    $collectionId TEXT NOT NULL,
    $prompt TEXT NOT NULL,
    $verseText TEXT,
    $hint TEXT,
    $modifiedDate INTEGER,
    $nextDueDate INTEGER,
    $interval INTEGER DEFAULT 0,
    $synced BOOLEAN DEFAULT FALSE,
    FOREIGN KEY($collectionId) 
    REFERENCES ${CollectionEntry.tableName} (${CollectionEntry.id}),
    UNIQUE ($collectionId, $prompt)
  )
  ''';
}

class CollectionEntry {
  // List table
  static const String tableName = "collection";

  // Column names
  static const String id = '_id';
  static const String name = 'name';
  // seconds since epoch
  static const String modifiedDate = 'access_date'; // repurpose unused column
  static const String synced = 'synced';

  // SQL statements
  static const String createTable = '''
  CREATE TABLE $tableName (
    $id TEXT PRIMARY KEY,
    $name TEXT NOT NULL UNIQUE,
    $modifiedDate INTEGER,
    $synced BOOLEAN DEFAULT FALSE)
  ''';
}

class DeletedVerseEntry {
  // Deleted verses table
  static const String tableName = "deleted_verses";

  // Column names
  static const String id = '_id';
  // seconds since epoch
  static const String date = 'date';

  // SQL statements
  static const String createTable = '''
  CREATE TABLE $tableName (
    $id TEXT PRIMARY KEY,
    $date INTEGER)
  ''';
}

class DeletedCollectionEntry {
  // Deleted collections table
  static const String tableName = "deleted_collections";

  // Column names
  static const String id = '_id';
  // seconds since epoch
  static const String date = 'date';

  // SQL statements
  static const String createTable = '''
  CREATE TABLE $tableName (
    $id TEXT PRIMARY KEY,
    $date INTEGER)
  ''';
}
