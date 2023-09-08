import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class VerseBrowserManager {
  final dataRepo = getIt<DataRepository>();
  final listNotifier = ValueNotifier<List<Verse>>([]);

  late String _collectionId;
  late List<Collection> _collections;

  Future<void> init(String collectionId) async {
    _collectionId = collectionId;
    _collections = await dataRepo.fetchCollections();
    final list = await dataRepo.fetchAllVerses(collectionId);
    listNotifier.value = list;
  }

  Future<void> deleteVerse(int index) async {
    final list = listNotifier.value.toList();
    final verse = list[index];
    await dataRepo.deleteVerse(verseId: verse.id);
    list.removeAt(index);
    listNotifier.value = list;
  }

  Verse verseFor(int index) {
    return listNotifier.value[index];
  }

  void onFinishedEditing(String? verseId) async {
    init(_collectionId);
  }

  Future<void> resetDueDate({required int index}) async {
    final list = listNotifier.value;
    final verse = list[index];
    final updated = Verse(
      id: verse.id,
      prompt: verse.prompt,
      text: verse.text,
    );
    await dataRepo.updateVerse(_collectionId, updated);
  }

  bool shouldShowMoveMenuItem() => _collections.length > 1;

  List<Collection> otherCollections() {
    return _collections
        .where((collection) => collection.id != _collectionId)
        .toList();
  }

  void moveVerse(int index, String toCollectionId) async {
    final list = listNotifier.value.toList();
    final verse = list[index];
    await dataRepo.updateVerse(toCollectionId, verse);
    list.removeAt(index);
    listNotifier.value = list;
  }
}
