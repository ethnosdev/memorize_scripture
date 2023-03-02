import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPageManager {
  final versionNotifier = ValueNotifier<String>('');

  Future<void> lookupVersionNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();
    versionNotifier.value = packageInfo.version;
  }
}
