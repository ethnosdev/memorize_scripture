import 'package:memorize_scripture/services/data_repository.dart';

class EmptyDataRepo implements DataRepository {
  @override
  Future<List<String>> fetchCollectionNames() async => [];

  @override
  Future<String> fetchVerse() async => '';
}
