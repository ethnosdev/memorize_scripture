import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';

class EditVersePageManager {
  final verseNotifier = ValueNotifier<Verse?>(null);
  final dataRepo = getIt<DataRepository>();

  late String _collectionId;
  late String _verseId;

  Future<void> init({
    required String collectionId,
    required String verseId,
  }) async {
    _collectionId = collectionId;
    _verseId = verseId;

    verseNotifier.value = await dataRepo.fetchVerse(
      collectionId: collectionId,
      verseId: verseId,
    );
  }

  Future<void> saveVerse({
    required String prompt,
    required String answer,
  }) async {
    await dataRepo.upsertVerse(
      _collectionId,
      Verse(
        id: _verseId,
        prompt: prompt,
        answer: answer,
      ),
    );
  }
}
