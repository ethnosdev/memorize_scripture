import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository.dart';
import 'package:memorize_scripture/services/sample_verses.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);

  Future<void> init() async {
    await _setDarkLightTheme();
    await _onFirstRun();
  }

  Future<void> _setDarkLightTheme() async {
    final userSettings = getIt<UserSettings>();
    final isDarkTheme = await userSettings.getDarkMode();
    setDarkTheme(isDarkTheme);
  }

  Future<void> _onFirstRun() async {
    final isFirstRun = await _isFirstRun();
    if (!isFirstRun) return;
    debugPrint('on first run');
    await _copySampleCollection();
  }

  Future<bool> _isFirstRun() async {
    final userSettings = getIt<UserSettings>();
    final oldNumber = await userSettings.getBuildNumber() ?? 0;
    final packageInfo = await PackageInfo.fromPlatform();
    final currentNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
    if (currentNumber > oldNumber) {
      userSettings.setBuildNumber(currentNumber);
    }
    return oldNumber == 0;
  }

  Future<void> _copySampleCollection() async {
    final dataRepo = getIt<DataRepository>();
    await dataRepo.batchUpdateVerses(Collection(
      id: 'sample',
      name: 'Sample pack',
      verses: starterVersesWeb,
    ));
  }

  void setDarkTheme(bool isDark) {
    themeListener.value = (isDark) ? _darkTheme : _lightTheme;
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.light().disabledColor),
  ),
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.dark().disabledColor),
  ),
);
