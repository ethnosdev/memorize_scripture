import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/notification_service.dart';
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

  String get dailyLimit {
    final value = userSettings.getDailyLimit;
    if (value >= UserSettings.defaultDailyLimit) return '';
    return userSettings.getDailyLimit.toString();
  }

  String get maxInterval {
    final value = userSettings.getMaxInterval;
    if (value >= UserSettings.defaultMaxInterval) return '';
    return value.toString();
  }

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

  String validateDailyLimit(String value) {
    int result = int.tryParse(value) ?? UserSettings.defaultDailyLimit;
    if (result < 0) return UserSettings.defaultDailyLimit.toString();
    return result.toString();
  }

  Future<void> updateDailyLimit(String number) async {
    final limit = int.tryParse(number);
    if (limit == null) return;
    await userSettings.setDailyLimit(limit);
    notifyListeners();
  }

  String validateMaxInterval(String value) {
    int result = int.tryParse(value) ?? UserSettings.defaultMaxInterval;
    if (result < 1) return UserSettings.defaultMaxInterval.toString();
    return result.toString();
  }

  Future<void> updateMaxInterval(String number) async {
    final interval = int.tryParse(number);
    if (interval == null) return;
    await userSettings.setMaxInterval(interval);
    notifyListeners();
  }

  Future<void> setTwoButtonMode(bool value) async {
    await userSettings.setTwoButtonMode(value);
    notifyListeners();
  }

  Future<void> setNotifications(bool isOn) async {
    await userSettings.setNotifications(isOn);
    final service = getIt<NotificationService>();
    notifyListeners();
    if (!isOn) {
      await service.clearNotifications();
      return;
    }
    final isGranted = await _requestNotificationPermission();
    if (isGranted) {
      await service.scheduleNotifications();
    } else {
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
              ?.requestNotificationsPermission() ??
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
    final service = getIt<NotificationService>();
    await service.scheduleNotifications();
  }
}
