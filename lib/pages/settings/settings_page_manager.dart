import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<AppManager>();
  final userSettings = getIt<UserSettings>();

  void init() {
    final (hour, minute) = userSettings.getNotificationTime;
    _notificationHour = hour;
    _notificationMinute = minute;
  }

  bool get isDarkMode => userSettings.isDarkMode;

  int get dailyLimit => userSettings.getDailyLimit;

  bool get isTwoButtonMode => userSettings.isTwoButtonMode;

  bool get isNotificationsOn => userSettings.isNotificationsOn;

  String get notificationTimeDisplay {
    String paddedMinute = '$_notificationMinute'.padLeft(2, '0');
    return '$_notificationHour:$paddedMinute';
  }

  late int _notificationHour;
  int get notificationTimeHour => _notificationHour;

  late int _notificationMinute;
  int get notificationTimeMinute => _notificationMinute;

  Future<void> setDarkMode(bool value) async {
    themeManager.setDarkTheme(value);
    await userSettings.setDarkMode(value);
    notifyListeners();
  }

  Future<void> updateDailyLimit(int number) async {
    await userSettings.setDailyLimit(number);
    notifyListeners();
  }

  int validateDailyLimit(String value) {
    int result = int.tryParse(value) ?? UserSettings.defaultDailyLimit;
    if (result < 0) return UserSettings.defaultDailyLimit;
    return result;
  }

  Future<void> setTwoButtonMode(bool value) async {
    await userSettings.setTwoButtonMode(value);
    notifyListeners();
  }

  Future<void> setNotifications(bool isOn) async {
    await userSettings.setNotifications(isOn);
    notifyListeners();
    if (!isOn) return;
    final isGranted = await _requestNotificationPermission();
    print('isGranted: $isGranted');
    if (!isGranted) {
      await userSettings.setNotifications(isGranted);
      notifyListeners();
    }
  }

  Future<bool> _requestNotificationPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      return await plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true) ??
          false;
    } else if (Platform.isAndroid) {
      return await plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestPermission() ??
          false;
    }
    debugPrint('Trying to set notifications for unimplemented platform');
    return false;
  }

  Future<void> setNotificationTime({
    required int hour,
    required int minute,
  }) async {
    _notificationHour = hour;
    _notificationMinute = minute;
    await userSettings.setNotificationTime(hour: hour, minute: minute);
    notifyListeners();
  }
}
