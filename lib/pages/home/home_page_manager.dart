import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/local_storage/sqflite/database.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class HomePageManager {
  HomePageManager({
    LocalStorage? dataRepository,
    UserSettings? userSettings,
  }) {
    this.dataRepository = dataRepository ?? getIt<LocalStorage>();
    this.userSettings = userSettings ?? getIt<UserSettings>();
  }
  late final LocalStorage dataRepository;
  late final UserSettings userSettings;

  final collectionNotifier =
      ValueNotifier<HomePageUiState>(LoadingCollections());

  List<Collection> get _getList =>
      (collectionNotifier.value as LoadedCollections).list;

  bool get isLoggedIn => false;

  Future<void> init() async {
    await _reloadCollections();
  }

  Future<void> _reloadCollections() async {
    final collections = await dataRepository.fetchCollections();
    final withPins = _updatePinnedStatus(collections);
    final sorted = _sortPinned(withPins);
    collectionNotifier.value = LoadedCollections(sorted);
  }

  List<Collection> _updatePinnedStatus(List<Collection> collections) {
    final pinnedIds = userSettings.pinnedCollections;
    final withPins = collections.map((c) {
      return c.copyWith(isPinned: pinnedIds.contains(c.id));
    }).toList();
    return withPins;
  }

  List<Collection> _sortPinned(List<Collection> collections) {
    final sortedCollections = collections.toList();
    sortedCollections.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return a.name.compareTo(b.name);
    });
    return sortedCollections;
  }

  Future<void> addCollection(String? name) async {
    if (name == null || name.isEmpty) return;
    final collection = Collection(
      id: const Uuid().v4(),
      name: name,
    );
    await dataRepository.insertCollection(collection);
    await _reloadCollections();
  }

  Future<void> renameCollection({required int index, String? newName}) async {
    if (newName == null || newName.isEmpty) return;
    final oldCollection = _getList[index];
    await dataRepository.updateCollection(
      oldCollection.copyWith(name: newName),
    );
    await _reloadCollections();
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

  Future<void> shareCollection({
    required int index,
    Rect? sharePositionOrigin,
  }) async {
    final collection = _getList[index];
    final name = collection.name.replaceAll(' ', '-');
    await backupCollections(
      collectionId: collection.id,
      name: name,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<void> backupCollections({
    String? collectionId,
    String? name,
    Rect? sharePositionOrigin,
  }) async {
    final collections = await dataRepository.dumpCollections(collectionId);
    var verses = await dataRepository.dumpVerses(collectionId);

    final backup = {
      'date': _dateToSecondsSinceEpoch(DateTime.now()),
      'version': databaseVersion,
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

    Share.shareXFiles(
      [XFile(file.path)],
      sharePositionOrigin: sharePositionOrigin,
    );
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

  void togglePin(Collection collection) {
    final collections = _getList.toList();
    final index = collections.indexOf(collection);
    collections[index] = collection.copyWith(isPinned: !collection.isPinned);
    final reordered = _sortPinned(collections);
    collectionNotifier.value = LoadedCollections(reordered);
    final pinnedIds = reordered
        .where((c) => c.isPinned) //
        .map((c) => c.id)
        .toList();
    userSettings.setPinnedCollections(pinnedIds);
  }

  Future<void> sync() async {
    // TODO: show overlay while syncing
  }
}

sealed class HomePageUiState {}

class LoadingCollections extends HomePageUiState {}

class LoadedCollections extends HomePageUiState {
  LoadedCollections(this.list);
  final List<Collection> list;
}
