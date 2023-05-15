import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class EditVersePageManager {
  final verseNotifier = ValueNotifier<Verse?>(null);
  final dataRepo = getIt<DataRepository>();

  late String _collectionId;

  Future<void> init({
    required String collectionId,
    required String verseId,
  }) async {
    _collectionId = collectionId;
    verseNotifier.value = await dataRepo.fetchVerse(verseId: verseId);
  }

  Future<void> saveVerse({
    required String prompt,
    required String answer,
  }) async {
    final verse = verseNotifier.value;
    if (verse == null) return;
    await dataRepo.updateVerse(
      _collectionId,
      verse.copyWith(
        prompt: prompt,
        answer: answer,
      ),
    );
  }

  String formatDueDate(DateTime? date) {
    if (date == null) return '---';
    return '${date.year}.${date.month}.${date.day}';
  }

  /// Update the UI but don't save the verse yet
  void softResetProgress(Verse? verse) {
    verseNotifier.value = verse;
  }
}
