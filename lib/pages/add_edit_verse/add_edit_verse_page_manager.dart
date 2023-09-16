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

  String updateHighlight(String text, int startIndex, int endIndex) {
    int start = _moveStartBack(text, startIndex);
    int end = _moveEndUp(text, endIndex);
    final startIsHighlighted = _isHighlighted(text, start);
    final endIsHighlighted = _isHighlighted(text, end);
    if (start == end) {
      if (startIsHighlighted && endIsHighlighted) {
        return _unhighlight(text, start);
      }
      // if not bold then
      // move start to beginning of word
      // move end to end of word
      // if start still == end then do nothing (not in word)
    }

    // range does not contain **
    // then insert ** at start and ** at end

    // range contains *
    // 1. start and end bold:
    //  remove all ** from start to end
    if (startIsHighlighted && endIsHighlighted) {
      return _unhighlightRange(text, start, end);
    }
    // 2. start and end NOT bold:
    //  remove all ** from start to end
    //  insert ** at start and ** at end
    if (!startIsHighlighted && !endIsHighlighted) {
      final value = _unhighlightRange(text, start, end);
      return _highlightRange(text, start, end);
    }
    // 3. only start is bold:
    //  remove all ** from start to end
    //  insert ** at end
    // 4. only end is bold:
    //  remove all ** from start to end
    //  insert ** at start

    // edge cases
    //  bbbbs**nnne (same as 3)
    //  bbbb*s*nnne (move s back then 3)
    //  bbbb**snnne (move s back then 3)
    //  nnnns**bbbe (same as 4)
    //  nnnn*s*bbbe (move s back then 4)
    //  nnnn**sbbbe (move s back then 4)

    //  sbbbb**ennn (same as 3)
    //  sbbbb*e*nnn (move e up then 3)
    //  sbbbbe**nnne (move e up then 3)
    //  snnnn**ebbb (same as 4)
    //  snnnn*e*bbb (move e up then 4)
    //  snnnne**bbb (move e up then 4)

    // Summary: move s back and e up to start with
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

  int _moveStartBack(String text, int startIndex) {
    int newStart = startIndex;
    for (int i = startIndex - 1; i >= 0; i--) {
      if (text[i] == '*') newStart = i;
    }
    return newStart;
  }

  int _moveEndUp(String text, int endIndex) {
    int newEnd = endIndex;
    for (int i = endIndex; i < text.length; i++) {
      if (text[i] == '*') newEnd = i + 1;
    }
    return newEnd;
  }

  String _unhighlight(String text, int index) {
    final indexBefore = text.lastIndexOf('**', index);
    final indexAfter = text.indexOf('**', index);
    if (indexBefore == -1 || indexAfter == -1) return text;
    return _unhighlightRange(text, indexBefore, indexAfter + 2);
    // final before = text.substring(0, indexBefore);
    // final middle = text.substring(indexBefore + 2, indexAfter);
    // final after = text.substring(indexAfter + 2);
    // return '$before$middle$after';
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
}
