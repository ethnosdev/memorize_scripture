import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class HomePageManager {
  HomePageManager({DataRepository? dataRepository}) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
  }
  late final DataRepository dataRepository;

  final collectionNotifier = ValueNotifier<List<Collection>>([]);
  //List<Collection> _collections = [];

  Future<void> init() async {
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = collections;
  }

  Future<void> addCollection(String? name) async {
    if (name == null || name.isEmpty) return;
    final collection = Collection(name: name);
    await dataRepository.upsertCollection(collection);
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = collections;
  }

  Future<void> renameCollection({required int index, String? newName}) async {
    if (newName == null || newName.isEmpty) return;
    final oldCollection = collectionNotifier.value[index];
    await dataRepository.upsertCollection(
      oldCollection.copyWith(name: newName),
    );
    collectionNotifier.value = await dataRepository.fetchCollections();
  }

  void deleteCollection(int index) {
    final list = collectionNotifier.value.toList();
    final collection = list[index];
    list.removeAt(index);
    dataRepository.deleteCollection(collectionId: collection.id!);
    collectionNotifier.value = list;
  }

  String collectionNameAt(int index) {
    return collectionNotifier.value[index].name;
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
