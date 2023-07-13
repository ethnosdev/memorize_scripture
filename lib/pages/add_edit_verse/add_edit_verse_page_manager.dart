import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:uuid/uuid.dart';

class AddEditVersePageManager {
  final verseNotifier = ValueNotifier<Verse?>(null);
  final canAddNotifier = ValueNotifier<bool>(false);
  final alreadyExistsNotifier = ValueNotifier<bool>(false);

  final dataRepo = getIt<DataRepository>();

  String _prompt = '';
  String _verseText = '';
  late String _collectionId;
  Verse? _initialVerse;

  bool get hasUnsavedChanges => canAddNotifier.value;

  Future<void> init({
    required String collectionId,
    required String? verseId,
  }) async {
    _collectionId = collectionId;
    if (verseId == null) return;
    final verse = await dataRepo.fetchVerse(verseId: verseId);
    verseNotifier.value = verse;
    _initialVerse = verse;
    _prompt = verse?.prompt ?? '';
    _verseText = verse?.text ?? '';
  }

  void onPromptChanged({
    required String collectionId,
    required String prompt,
  }) {
    _prompt = prompt;
    dataRepo
        .promptExists(collectionId: collectionId, prompt: prompt)
        .then((exists) {
      if (_initialVerse?.prompt != prompt) {
        alreadyExistsNotifier.value = exists;
      }
      canAddNotifier.value = !exists && _bothNotEmpty && _changesMade;
    });
  }

  void onAnswerChanged(String verseText) {
    _verseText = verseText;
    canAddNotifier.value = _bothNotEmpty && _changesMade;
  }

  bool get _changesMade {
    return _prompt != _initialVerse?.prompt ||
        _verseText != _initialVerse?.text;
  }

  bool get _bothNotEmpty => _prompt.isNotEmpty && _verseText.isNotEmpty;

  Future<void> addVerse({
    required String prompt,
    required String verseText,
  }) async {
    dataRepo.insertVerse(
      _collectionId,
      Verse(
        id: const Uuid().v4(),
        prompt: prompt,
        text: verseText,
      ),
    );
    canAddNotifier.value = false;
  }

  Future<void> updateVerse({
    required String verseId,
    required String prompt,
    required String text,
  }) async {
    dataRepo.updateVerse(
      _collectionId,
      Verse(
        id: verseId,
        prompt: prompt,
        text: text,
      ),
    );
  }
}
