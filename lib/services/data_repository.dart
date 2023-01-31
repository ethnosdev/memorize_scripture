abstract class DataRepository {
  Future<List<String>> fetchCollectionNames();

  Future<String> fetchVerse();
}

class FakeData implements DataRepository {
  @override
  Future<List<String>> fetchCollectionNames() async {
    return [
      'Navigator verse pack',
      'Proverbs 3',
      'John 15',
    ];
  }

  @override
  Future<String> fetchVerse() async {
    return 'I am the true vine and my father is the vinedresser. (ESV)';
  }
}
