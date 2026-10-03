import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';

class AppManager {
  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final userSettings = getIt<UserSettings>();

  Future<void> init() async {
    await userSettings.init();
    themeNotifier.value = userSettings.themeMode;
    await getIt<LocalStorage>().init();
    try {
      final notificationService = getIt<NotificationService>();
      await notificationService.init();
      await notificationService.scheduleNotifications();
    } catch (e, stack) {
      debugPrint('Error initializing notifications: $e\n$stack');
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeNotifier.value = mode;
  }

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.yellow,
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.yellow,
    brightness: Brightness.dark,
  );
}
