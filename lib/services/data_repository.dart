abstract class DataRepository {
  Future<List<String>> fetchCollectionNames();
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
}
