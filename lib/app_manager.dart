import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/data_repository/data_repository.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);
  final userSettings = getIt<UserSettings>();

  Future<void> init() async {
    await userSettings.init();
    await _setDarkLightTheme();
    await getIt<DataRepository>().init();
    await _initNotifications();
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

Future<void> _initNotifications() async {
  tz.initializeTimeZones();
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  final notificationsPlugin = getIt<FlutterLocalNotificationsPlugin>();
  const androidSettings = AndroidInitializationSettings('notification_icon');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await notificationsPlugin.initialize(settings);
}
