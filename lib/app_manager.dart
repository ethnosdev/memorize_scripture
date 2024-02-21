import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';

class AppManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);
  final userSettings = getIt<UserSettings>();
  final notificationService = getIt<NotificationService>();

  Future<void> init() async {
    await userSettings.init();
    await _setDarkLightTheme();
    await getIt<LocalStorage>().init();
    await getIt<NotificationService>().init();
    await getIt<NotificationService>().scheduleNotifications();
  }

  Future<void> _setDarkLightTheme() async {
    final isDarkTheme = userSettings.isDarkMode;
    setDarkTheme(isDarkTheme);
  }

  void setDarkTheme(bool isDark) {
    themeListener.value = (isDark) ? _darkTheme : _lightTheme;
  }
}

final _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.yellow,
);

final _darkTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.yellow,
  brightness: Brightness.dark,
);
