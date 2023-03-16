import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class HomePageManager {
  HomePageManager({DataRepository? dataRepository}) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
  }
  late final DataRepository dataRepository;

  final collectionNotifier = ValueNotifier<List<String>>([]);
  List<Collection> _collections = [];

  Future<void> init() async {
    _collections = await dataRepository.fetchCollectionMetadata();
    collectionNotifier.value = _collections.map((c) => c.name).toList();
  }

  void addCollection(String? name) {
    if (name == null || name.isEmpty) return;
    final list = collectionNotifier.value.toList();
    list.add(name);
    collectionNotifier.value = list;
  }

  void onCollectionItemReordered(int oldIndex, int newIndex) {
    final list = collectionNotifier.value.toList();
    list.move(oldIndex, newIndex);
    collectionNotifier.value = list;
  }

  void renameCollection({required int index, String? newName}) {
    if (newName == null || newName.isEmpty) return;
    final list = collectionNotifier.value.toList();
    list[index] = newName;
    collectionNotifier.value = list;
  }

  void deleteCollection(int index) {
    final list = collectionNotifier.value.toList();
    list.removeAt(index);
    collectionNotifier.value = list;
  }

  String collectionNameAt(int index) {
    return collectionNotifier.value[index];
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
