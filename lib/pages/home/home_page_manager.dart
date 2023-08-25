import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class HomePageManager {
  HomePageManager({DataRepository? dataRepository}) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
  }
  late final DataRepository dataRepository;

  final collectionNotifier =
      ValueNotifier<HomePageUiState>(LoadingCollections());

  List<Collection> get _getList =>
      (collectionNotifier.value as LoadedCollections).list;

  Future<void> init() async {
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = LoadedCollections(collections);
  }

  Future<void> addCollection(String? name) async {
    if (name == null || name.isEmpty) return;
    final collection = Collection(
      id: const Uuid().v4(),
      name: name,
    );
    await dataRepository.insertCollection(collection);
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = LoadedCollections(collections);
  }

  Future<void> renameCollection({required int index, String? newName}) async {
    if (newName == null || newName.isEmpty) return;
    final oldCollection = _getList[index];
    await dataRepository.updateCollection(
      oldCollection.copyWith(name: newName),
    );
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = LoadedCollections(collections);
  }

  Future<void> resetDueDates({
    required int index,
    required void Function(int numberReset) onFinished,
  }) async {
    final collection = _getList[index];
    final count = await dataRepository.resetDueDates(
      collectionId: collection.id,
    );
    onFinished.call(count);
  }

  void deleteCollection(int index) {
    final list = _getList.toList();
    final collection = list[index];
    list.removeAt(index);
    dataRepository.deleteCollection(collectionId: collection.id);
    collectionNotifier.value = LoadedCollections(list);
  }

  Collection collectionAt(int index) {
    return (collectionNotifier.value as LoadedCollections).list[index];
  }

  Future<void> shareCollection({required int index}) async {
    final collection = _getList[index];
    final name = collection.name.replaceAll(' ', '-');
    await backupCollections(collectionId: collection.id, name: name);
  }

  Future<void> backupCollections({String? collectionId, String? name}) async {
    final collections = await dataRepository.dumpCollections(collectionId);
    var verses = await dataRepository.dumpVerses(collectionId);

    final backup = {
      'date': _dateToSecondsSinceEpoch(DateTime.now()),
      'version': 2, // should match the database version
      'collections': collections,
      'verses': verses,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final serialized = encoder.convert(backup);
    final uint8list = Uint8List.fromList(utf8.encode(serialized));
    final directory = await getTemporaryDirectory();
    final prefix = name ?? 'ms-backup';
    final time = DateTime.now().toIso8601String();
    final timeFormatted = time.split('.').first.replaceAll(':', '-');
    final fileName = '$prefix-$timeFormatted.json';
    final path = join(directory.path, fileName);
    final file = File(path);
    await file.writeAsBytes(uint8list);

    Share.shareXFiles([XFile(file.path)]);
  }

  int? _dateToSecondsSinceEpoch(DateTime? date) {
    if (date == null) return null;
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  void import(void Function(String message) onResult) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles();
    } on Exception catch (e) {
      onResult.call('FilePicker error: ${e.toString()}');
    }
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) {
      onResult.call("The file couldn't be read.");
      return;
    }
    final file = File(path);
    final jsonString = await file.readAsString();
    try {
      dynamic json = jsonDecode(jsonString);
      final collections =
          (json['collections'] as List).cast<Map<String, Object?>>();
      final verses = (json['verses'] as List).cast<Map<String, Object?>>();
      await dataRepository.restoreCollections(collections);
      final (added, updated, errorCount) =
          await dataRepository.restoreVerses(verses);
      onResult.call(_resultString(added, updated, errorCount));
    } on FormatException {
      onResult.call('The data in the file was in the wrong format.');
    }
    init();
  }

  String _resultString(int added, int updated, int errorCount) {
    // 000
    if (added == 0 && updated == 0 && errorCount == 0) {
      return 'No verses were added or updated.';
    }
    // 001
    if (added == 0 && updated == 0 && errorCount != 0) {
      final verses = (errorCount == 1) ? 'verse' : 'verses';
      return '$errorCount $verses had errors and couldn\'t be imported.';
    }
    // 010
    if (added == 0 && updated != 0 && errorCount == 0) {
      return '$updated ${_versesWere(updated)} updated.';
    }
    // 011
    if (added == 0 && updated != 0 && errorCount != 0) {
      return '$updated ${_versesWere(updated)} updated, '
          'but $errorCount ${_versesWere(errorCount)} not '
          'added because of errors.';
    }
    // 100
    if (added != 0 && updated == 0 && errorCount == 0) {
      return '$added ${_versesWere(added)} added.';
    }
    // 101
    if (added != 0 && updated == 0 && errorCount != 0) {
      return '$added ${_versesWere(added)} added, '
          'but $errorCount ${_versesWere(errorCount)} not '
          'added because of errors.';
    }
    // 110
    if (added != 0 && updated != 0 && errorCount == 0) {
      return '$added verses were added, and $updated verses were updated.';
    }

    /// 111
    return '$added ${_versesWere(added)} added, '
        '$updated ${_versesWere(updated)} updated, '
        'and $errorCount ${_versesWere(errorCount)} not added because of errors.';
  }

  String _versesWere(int count) {
    if (count == 1) return 'verse was';
    return 'verses were';
  }
}

sealed class HomePageUiState {}

class LoadingCollections extends HomePageUiState {}

class LoadedCollections extends HomePageUiState {
  LoadedCollections(this.list);
  final List<Collection> list;
}
