import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';

class HomePageManager {
  final collectionNotifier = ValueNotifier<List<String>>([]);
  final dataRepository = getIt<DataRepository>();

  Future<void> init() async {
    collectionNotifier.value = await dataRepository.fetchCollectionNames();
  }
}