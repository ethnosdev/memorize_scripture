import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/verse.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:uuid/uuid.dart';

class AddVersePageManager {
  final canAddNotifier = ValueNotifier<bool>(false);
  final alreadyExistsNotifier = ValueNotifier<bool>(false);

  final dataRepo = getIt<DataRepository>();

  String _prompt = '';
  String _answer = '';

  void onPromptChanged({
    required String collectionId,
    required String prompt,
  }) {
    _prompt = prompt;
    dataRepo
        .promptExists(collectionId: collectionId, prompt: prompt)
        .then((exists) {
      alreadyExistsNotifier.value = exists;
      canAddNotifier.value = !exists && _bothEmpty();
    });
  }

  void onAnswerChanged(String answer) {
    _answer = answer;
    canAddNotifier.value = _bothEmpty();
  }

  bool _bothEmpty() => _prompt.isNotEmpty && _answer.isNotEmpty;

  Future<void> addVerse({
    required String collectionId,
    required String prompt,
    required String answer,
  }) async {
    dataRepo.insertVerse(
      collectionId,
      Verse(
        id: const Uuid().v4(),
        prompt: prompt,
        answer: answer,
      ),
    );
    canAddNotifier.value = false;
  }

  Future<void> updateVerse({
    required String collectionId,
    required String verseId,
    required String prompt,
    required String answer,
  }) async {
    dataRepo.updateVerse(
      collectionId,
      Verse(
        id: verseId,
        prompt: prompt,
        answer: answer,
      ),
    );
  }
}
