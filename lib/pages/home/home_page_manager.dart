import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class HomePageManager {
  HomePageManager({DataRepository? dataRepository}) {
    this.dataRepository = dataRepository ?? getIt<DataRepository>();
  }
  late final DataRepository dataRepository;

  final collectionNotifier = ValueNotifier<List<Collection>>([]);

  Future<void> init() async {
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = collections;
  }

  Future<void> addCollection(String? name) async {
    if (name == null || name.isEmpty) return;
    final collection = Collection(
      id: const Uuid().v4(),
      name: name,
    );
    await dataRepository.insertCollection(collection);
    final collections = await dataRepository.fetchCollections();
    collectionNotifier.value = collections;
  }

  Future<void> renameCollection({required int index, String? newName}) async {
    if (newName == null || newName.isEmpty) return;
    final oldCollection = collectionNotifier.value[index];
    await dataRepository.updateCollection(
      oldCollection.copyWith(name: newName),
    );
    collectionNotifier.value = await dataRepository.fetchCollections();
  }

  void deleteCollection(int index) {
    final list = collectionNotifier.value.toList();
    final collection = list[index];
    list.removeAt(index);
    dataRepository.deleteCollection(collectionId: collection.id);
    collectionNotifier.value = list;
  }

  Collection collectionAt(int index) {
    return collectionNotifier.value[index];
  }

  Future<void> backupCollections() async {
    final collections = await dataRepository.dumpCollections();
    final verses = await dataRepository.dumpVerses();

    final backup = {
      'date': _dateToSecondsSinceEpoch(DateTime.now()),
      'version': '1', // should match the database version
      'collections': collections,
      'verses': verses,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final serialized = encoder.convert(backup);
    final uint8list = Uint8List.fromList(utf8.encode(serialized));
    final directory = await getTemporaryDirectory();
    final timeString =
        DateTime.now().toIso8601String().split('.').first.replaceAll(':', '-');
    final fileName = 'ms-backup-$timeString.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(uint8list);

    Share.shareXFiles([XFile(file.path)]);
  }

  int? _dateToSecondsSinceEpoch(DateTime? date) {
    if (date == null) return null;
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  void restoreBackup(void Function(String message) onResult) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
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
      final (added, updated) = await dataRepository.restoreVerses(verses);
      onResult.call(_resultString(added, updated));
    } on FormatException {
      onResult.call('The data in the file was in the wrong format.');
    }
    init();
  }

  String _resultString(int added, int updated) {
    if (added == 0) {
      return '$updated verses updated';
    }
    if (updated == 0) {
      return '$added verses added';
    }
    return '$added verses added and $updated verses updated.';
  }
}
