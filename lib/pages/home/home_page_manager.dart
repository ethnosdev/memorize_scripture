import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
      'date': DateTime.now().millisecondsSinceEpoch,
      'version': '1', // should match the database version
      'collections': collections,
      'verses': verses,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final serialized = encoder.convert(backup);
    final uint8list = Uint8List.fromList(utf8.encode(serialized));
    final directory = await getTemporaryDirectory();
    final fileName = 'ms-backup-${DateTime.now().toIso8601String()}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(uint8list);

    print(serialized);
    Share.shareXFiles([XFile(file.path)]);
  }

  void restoreBackup() {}
}
