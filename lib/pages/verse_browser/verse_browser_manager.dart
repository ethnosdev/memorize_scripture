import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class VerseBrowserManager {
  final dataRepo = getIt<DataRepository>();
  final listNotifier = ValueNotifier<List<Verse>>([]);

  Future<void> init(String collectionId) async {
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
}
