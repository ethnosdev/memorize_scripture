class VerseEntry {
  // Vocab table
  static const String verseTable = "verses";

  // Column names
  static const String id = '_id';
  static const String collectionId = 'collection_id';
  static const String prompt = 'prompt';
  static const String answer = 'answer';
  // seconds since epoch, new verses default to null
  static const String nextDueDate = 'next_due_date';
  // interval in days
  static const String interval = 'interval';

  // SQL statements
  static const String createVocabTable = '''
CREATE TABLE $verseTable (
  $id TEXT PRIMARY KEY,
  $collectionId TEXT NOT NULL,
  $prompt TEXT NOT NULL UNIQUE,
  $answer TEXT,
  $nextDueDate INTEGER,
  $interval INTEGER DEFAULT 0,
  FOREIGN KEY($collectionId) 
  REFERENCES ${CollectionEntry.collectionTable} (${CollectionEntry.id}))
''';
}

class CollectionEntry {
  // List table
  static const String collectionTable = "collection";

  // Column names
  static const String id = '_id';
  static const String name = 'name';

  // SQL statements
  static const String createCollectionTable = '''
CREATE TABLE $collectionTable (
  $id TEXT PRIMARY KEY,
  $name TEXT NOT NULL UNIQUE)
''';
}
