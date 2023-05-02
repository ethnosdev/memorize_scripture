import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/color.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/user_settings.dart';

// TODO: rename this to theme manager?
class AppManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);

  Future<void> init() async {
    await _setDarkLightTheme();
    // await _onFirstRun();
    await getIt<DataRepository>().init();
  }

  Future<void> _setDarkLightTheme() async {
    final userSettings = getIt<UserSettings>();
    final isDarkTheme = await userSettings.getDarkMode();
    setDarkTheme(isDarkTheme);
  }

  void setDarkTheme(bool isDark) {
    themeListener.value = (isDark) ? _darkTheme : _lightTheme;
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: customYellow,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.light().disabledColor),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    foregroundColor: customYellow.shade900,
  )),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
    foregroundColor: customYellow.shade900,
  )),
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.dark().disabledColor),
  ),
);
