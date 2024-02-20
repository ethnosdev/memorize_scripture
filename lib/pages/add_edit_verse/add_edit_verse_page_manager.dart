import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/data_repository.dart';
import 'package:uuid/uuid.dart';

class AddEditVersePageManager {
  final verseNotifier = ValueNotifier<Verse?>(null);
  final canAddNotifier = ValueNotifier<bool>(false);
  final alreadyExistsNotifier = ValueNotifier<bool>(false);
  final showHintBoxNotifier = ValueNotifier<bool>(false);

  final dataRepo = getIt<LocalStorage>();

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

  void onPromptChanged(String prompt) {
    _prompt = prompt;
    dataRepo
        .promptExists(collectionId: _collectionId, prompt: prompt)
        .then((exists) {
      if (_initialVerse?.prompt != prompt) {
        alreadyExistsNotifier.value = exists;
      }
      canAddNotifier.value = !exists && _promptVerseNotEmpty && _changesMade;
    });
  }

  void onVerseTextChanged(String verseText) {
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
    showHintBoxNotifier.value = false;
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

  /// Returns the updated text and the new cursor position
  (String, int) updateHighlight(String text, int startIndex, int endIndex) {
    if (startIndex != endIndex) {
      final updated = _highlightRange(text, startIndex, endIndex);
      return (updated, startIndex + 2);
    }
    if (_isHighlighted(text, startIndex)) {
      final updated = _unhighlight(text, startIndex);
      return (updated, startIndex - 2);
    }
    final (start, end) = _getWordRange(text, startIndex);
    if (start == end) return (text, startIndex);
    final updated = _highlightRange(text, start, end);
    return (updated, startIndex + 2);
  }

  bool _isHighlighted(String text, int index) {
    bool isHighlighted = false;
    var match = text.indexOf('**');
    while (match != -1 && match < index) {
      isHighlighted = !isHighlighted;
      match = text.indexOf('**', match + 2);
    }
    return isHighlighted;
  }

  String _unhighlight(String text, int index) {
    final start = max(index - 1, 0);
    final indexBefore = text.lastIndexOf('**', start);
    final indexAfter = text.indexOf('**', index);
    if (indexBefore == -1 || indexAfter == -1) return text;
    return _unhighlightRange(text, indexBefore, indexAfter + 2);
  }

  String _unhighlightRange(String text, int start, int end) {
    final target = text.substring(start, end);
    final modified = target.replaceAll('*', '');
    return text.substring(0, start) + modified + text.substring(end);
  }

  String _highlightRange(String text, int start, int end) {
    final before = text.substring(0, start);
    final middle = text.substring(start, end);
    final after = text.substring(end);
    return '$before**$middle**$after';
  }

  (int start, int end) _getWordRange(String text, int index) {
    int start = index;
    int end = index;
    while (start > 0 && _isWordCharacter(text[start - 1])) {
      start--;
    }
    while (end < text.length && _isWordCharacter(text[end])) {
      end++;
    }
    return (start, end);
  }

  bool _isWordCharacter(String c) {
    return RegExp(r'\w').hasMatch(c);
  }
}
