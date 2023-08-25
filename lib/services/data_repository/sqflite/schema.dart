class VerseEntry {
  // Vocab table
  static const String verseTable = "verses";

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

  // SQL statements
  static const String createVocabTable = '''
  CREATE TABLE $verseTable (
    $id TEXT PRIMARY KEY,
    $collectionId TEXT NOT NULL,
    $prompt TEXT NOT NULL,
    $verseText TEXT,
    $hint TEXT,
    $modifiedDate INTEGER,
    $nextDueDate INTEGER,
    $interval INTEGER DEFAULT 0,
    FOREIGN KEY($collectionId) 
    REFERENCES ${CollectionEntry.collectionTable} (${CollectionEntry.id}),
    UNIQUE ($collectionId, $prompt)
  )
  ''';
}

class CollectionEntry {
  // List table
  static const String collectionTable = "collection";

  // Column names
  static const String id = '_id';
  static const String name = 'name';
  // seconds since epoch
  static const String modifiedDate = 'access_date'; // repurpose unused column

  // SQL statements
  static const String createCollectionTable = '''
  CREATE TABLE $collectionTable (
    $id TEXT PRIMARY KEY,
    $name TEXT NOT NULL UNIQUE,
    $modifiedDate INTEGER)
  ''';
}
