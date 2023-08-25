import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:uuid/uuid.dart';

class AddEditVersePageManager {
  final verseNotifier = ValueNotifier<Verse?>(null);
  final canAddNotifier = ValueNotifier<bool>(false);
  final alreadyExistsNotifier = ValueNotifier<bool>(false);
  final showHintBoxNotifier = ValueNotifier<bool>(false);

  final dataRepo = getIt<DataRepository>();

  String _prompt = '';
  String _verseText = '';
  String _hint = '';
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
    _hint = verse?.hint ?? '';
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
      canAddNotifier.value = !exists && _promptVerseNotEmpty && _changesMade;
    });
  }

  void onAnswerChanged(String verseText) {
    _verseText = verseText;
    canAddNotifier.value = _promptVerseNotEmpty && _changesMade;
  }

  bool get _changesMade {
    return _prompt != _initialVerse?.prompt ||
        _verseText != _initialVerse?.text ||
        _hint != _initialVerse?.hint;
  }

  bool get _promptVerseNotEmpty => _prompt.isNotEmpty && _verseText.isNotEmpty;

  void onHintChanged(String hintText) {
    _hint = hintText;
    canAddNotifier.value = _promptVerseNotEmpty && _changesMade;
  }

  void onAddHintButtonPressed() {
    showHintBoxNotifier.value = true;
  }

  Future<void> addVerse({
    required String prompt,
    required String verseText,
    required String hint,
  }) async {
    dataRepo.insertVerse(
      _collectionId,
      Verse(
        id: const Uuid().v4(),
        prompt: prompt,
        text: verseText,
        hint: hint,
      ),
    );
    canAddNotifier.value = false;
  }

  Future<void> updateVerse({
    required String verseId,
    required String prompt,
    required String text,
    required String hint,
  }) async {
    final previous = await dataRepo.fetchVerse(verseId: verseId);
    await dataRepo.updateVerse(
      _collectionId,
      Verse(
        id: verseId,
        prompt: prompt,
        text: text,
        hint: hint,
        nextDueDate: previous?.nextDueDate,
        interval: previous?.interval ?? Duration.zero,
      ),
    );
  }
}
