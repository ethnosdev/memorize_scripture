class VerseEntry {
  // Vocab table
  static const String verseTable = "verses";

  // Column names
  static const String id = '_id';
  static const String collectionId = 'collection_id';
  static const String prompt = 'prompt';
  static const String answer = 'answer';
  static const String nextDueDate = 'next_due_date';
  static const String consecutiveCorrect = 'consecutive_correct';
  static const String easinessFactor = 'easiness_factor';

  // SQL statements
  static const String createVocabTable = '''
CREATE TABLE $verseTable (
  $id TEXT PRIMARY KEY,
  $collectionId TEXT NOT NULL,
  $prompt TEXT NOT NULL UNIQUE,
  $answer TEXT,
  $nextDueDate INTEGER DEFAULT 0,
  $consecutiveCorrect INTEGER DEFAULT 0,
  $easinessFactor REAL DEFAULT 2.5,
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
  static const String sequence = 'sequence';

  // SQL statements
  static const String createCollectionTable = '''
CREATE TABLE $collectionTable (
  $id TEXT PRIMARY KEY,
  $name TEXT NOT NULL UNIQUE,
  $sequence INTEGER NOT NULL)
''';
}
