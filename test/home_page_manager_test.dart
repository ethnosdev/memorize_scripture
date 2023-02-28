import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:test/test.dart';

import 'mocks/data_repo_mocks.dart';

void main() {
  // setUp(() => null);
  test('init', () async {
    final manager = HomePageManager(dataRepository: EmptyDataRepo());

    await manager.init();

    final list = manager.collectionNotifier.value;
    expect(list.isEmpty, true);
  });

  test('addCollection', () async {
    final manager = HomePageManager(dataRepository: EmptyDataRepo());
    await manager.init();

    manager.addCollection('name');

    final list = manager.collectionNotifier.value;
    expect(list.length, 1);
    expect(list.first, 'name');
  });

  test('renameCollection', () async {
    final manager = HomePageManager(dataRepository: EmptyDataRepo());
    await manager.init();
    manager.addCollection('name');

    manager.renameCollection(index: 0, newName: 'new name');

    final list = manager.collectionNotifier.value;
    expect(list.length, 1);
    expect(list.first, 'new name');
  });

  test('deleteCollection', () async {
    final manager = HomePageManager(dataRepository: EmptyDataRepo());
    await manager.init();
    manager.addCollection('name');

    manager.deleteCollection(0);

    final list = manager.collectionNotifier.value;
    expect(list.length, 0);
  });

  test('collectionNameAt', () async {
    final manager = HomePageManager(dataRepository: EmptyDataRepo());
    await manager.init();
    manager.addCollection('name');

    final name = manager.collectionNameAt(0);

    final list = manager.collectionNotifier.value;
    expect(list.length, 1);
    expect(name, 'name');
  });

  test('onCollectionItemReordered', () async {
    final manager = HomePageManager(dataRepository: EmptyDataRepo());
    await manager.init();
    manager.addCollection('one');
    manager.addCollection('two');
    var list = manager.collectionNotifier.value;
    expect(list.length, 2);
    expect(list.first, 'one');
    expect(list.last, 'two');

    manager.onCollectionItemReordered(0, 2);

    list = manager.collectionNotifier.value;
    expect(list.first, 'two');
    expect(list.last, 'one');

    manager.onCollectionItemReordered(1, 0);

    list = manager.collectionNotifier.value;
    expect(list.first, 'one');
    expect(list.last, 'two');
  });
}
