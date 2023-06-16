import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class VerseBrowserManager {
  final dataRepo = getIt<DataRepository>();
  final listNotifier = ValueNotifier<List<Verse>>([]);

  late String _collectionId;

  Future<void> init(String collectionId) async {
    _collectionId = collectionId;
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
    if (verseId == null) return;
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
}
