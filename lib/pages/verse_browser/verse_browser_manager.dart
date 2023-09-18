import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class VerseBrowserManager {
  final dataRepo = getIt<DataRepository>();
  final listNotifier = ValueNotifier<List<Verse>>([]);

  late String _collectionId;
  late List<Collection> _collections;

  void Function(String?)? onFinishedModifyingCollection;

  Future<void> init(String collectionId) async {
    _collectionId = collectionId;
    _collections = await dataRepo.fetchCollections();
    final list = await dataRepo.fetchAllVerses(collectionId);
    listNotifier.value = list;
  }

  Future<void> deleteVerse(Verse verse) async {
    await dataRepo.deleteVerse(verseId: verse.id);
    final list = listNotifier.value.toList();
    list.removeWhere((v) => v.id == verse.id);
    listNotifier.value = list;
    onFinishedModifyingCollection?.call(null);
  }

  void onFinishedEditing(String? verseId) async {
    init(_collectionId);
    onFinishedModifyingCollection?.call(verseId);
  }

  void copyVerseText(String verseText) {
    Clipboard.setData(ClipboardData(text: verseText));
  }

  Future<void> resetDueDate(Verse verse) async {
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

  void moveVerse(Verse verse, String toCollectionId) async {
    await dataRepo.updateVerse(toCollectionId, verse);
    final list = listNotifier.value.toList();
    list.removeWhere((v) => v.id == verse.id);
    listNotifier.value = list;
    onFinishedModifyingCollection?.call(null);
  }
}
