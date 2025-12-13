import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/highlighting.dart';
import 'package:memorize_scripture/common/sorting.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/user_settings.dart';

enum ViewOptions {
  empty,
  oneColumn,
  twoColumns,
}

class VerseBrowserManager extends ChangeNotifier {
  final dataRepo = getIt<LocalStorage>();
  var list = <Verse>[];
  var viewOptions = ViewOptions.empty;
  final userSettings = getIt<UserSettings>();

  late String _collectionId;
  late List<Collection> _collections;

  void Function(String?)? onFinishedModifyingCollection;

  Future<void> init(String collectionId) async {
    _collectionId = collectionId;
    _collections = await dataRepo.fetchCollections();
    if (userSettings.isBiblicalOrder) {
      sortCollectionsBiblically(_collections);
    }
    list = await dataRepo.fetchAllVersesInCollection(collectionId);
    if (userSettings.isBiblicalOrder) {
      sortVersesBiblically(list);
    }
    if (list.isNotEmpty) {
      final columns = userSettings.getBrowserPreferredNumberOfColumns;
      if (columns == 1) {
        viewOptions = ViewOptions.oneColumn;
      } else {
        viewOptions = ViewOptions.twoColumns;
      }
    }
    notifyListeners();
  }

  Future<void> deleteVerse(Verse verse) async {
    await dataRepo.deleteVerse(verseId: verse.id);
    list.removeWhere((v) => v.id == verse.id);
    notifyListeners();
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
    onFinishedModifyingCollection?.call(null);
  }

  bool shouldShowMoveMenuItem() => _collections.length > 1;

  List<Collection> otherCollections() {
    return _collections
        .where((collection) => collection.id != _collectionId)
        .toList();
  }

  void moveVerse(Verse verse, String toCollectionId) async {
    await dataRepo.updateVerse(toCollectionId, verse);
    list.removeWhere((v) => v.id == verse.id);
    notifyListeners();
    onFinishedModifyingCollection?.call(null);
  }

  void toggleView() {
    if (viewOptions == ViewOptions.oneColumn) {
      viewOptions = ViewOptions.twoColumns;
      userSettings.setBrowserPreferredNumberOfColumns(2);
    } else {
      viewOptions = ViewOptions.oneColumn;
      userSettings.setBrowserPreferredNumberOfColumns(1);
    }
    notifyListeners();
  }

  TextSpan formatText(String text, Color color) {
    return addHighlighting(text, color);
  }
}
