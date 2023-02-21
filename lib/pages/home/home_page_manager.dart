import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class HomePageManager {
  HomePageManager({DataRepository? dataRepository}) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
  }
  late final DataRepository dataRepository;

  final collectionNotifier = ValueNotifier<List<String>>([]);

  Future<void> init() async {
    collectionNotifier.value = await dataRepository.fetchCollectionNames();
  }

  void addCollection(String name) {
    if (name.isEmpty) return;
    final list = collectionNotifier.value.toList();
    list.add(name);
    collectionNotifier.value = list;
  }

  void onCollectionItemReordered(int oldIndex, int newIndex) {
    print('item $oldIndex moved to $newIndex');
    final list = collectionNotifier.value.toList();
    list.move(oldIndex, newIndex);
    collectionNotifier.value = list;
  }
}

extension _MovableList<T> on List<T> {
  void move(int oldIndex, int newIndex) {
    final copyOld = this[oldIndex];
    if (oldIndex > newIndex) {
      for (int i = oldIndex; i > newIndex; i--) {
        this[i] = this[i - 1];
      }
      this[newIndex] = copyOld;
    } else {
      for (int i = oldIndex; i < newIndex - 1; i++) {
        this[i] = this[i + 1];
      }
      this[newIndex - 1] = copyOld;
    }
  }
}
