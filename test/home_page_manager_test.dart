import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<DataRepository>()])
import 'home_page_manager_test.mocks.dart';

void main() {
  late MockDataRepository mockDataRepository;
  late HomePageManager manager;

  setUp(() {
    // Create and configure the mocks
    mockDataRepository = MockDataRepository();

    // Create the object under test
    manager = HomePageManager(
      dataRepository: mockDataRepository,
    );
  });

  test('init', () async {
    when(mockDataRepository.fetchCollections()).thenAnswer((_) async => []);

    await manager.init();

    final list = manager.collectionNotifier.value;
    expect(list.isEmpty, true);
  });

  test('collectionNameAt', () async {
    when(mockDataRepository.fetchCollections()).thenAnswer((_) async => [
          Collection(id: 'id', name: 'name'),
        ]);
    await manager.init();

    final collection = manager.collectionAt(0);

    final list = manager.collectionNotifier.value;
    expect(list.length, 1);
    expect(collection.name, 'name');
  });
}
