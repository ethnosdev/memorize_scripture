import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<AppManager>();
  final userSettings = getIt<UserSettings>();

  ThemeMode get themeMode => userSettings.themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    await userSettings.setThemeMode(mode);
    themeManager.setThemeMode(mode);
    notifyListeners();
  }

  double get fontSize => userSettings.fontSize;

  String validateFontSize(String value) {
    int? result = int.tryParse(value);
    if (result == null) {
      return UserSettings.defaultFontSize.round().toString();
    }
    if (result < UserSettings.minFontSize) {
      return UserSettings.minFontSize.round().toString();
    }
    if (result > UserSettings.maxFontSize) {
      return UserSettings.maxFontSize.round().toString();
    }
    return result.toString();
  }

  Future<void> updateFontSize(String number) async {
    final size = double.tryParse(number);
    if (size == null) return;
    await setFontSize(size);
  }

  Future<void> setFontSize(double size) async {
    await userSettings.setFontSize(size);
    themeManager.setFontSize(size);
    notifyListeners();
  }

  String get dailyLimit {
    final value = userSettings.getDailyLimit;
    if (value >= UserSettings.defaultDailyLimit) return '';
    return userSettings.getDailyLimit.toString();
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

  bool get isNotificationsOn => userSettings.isNotificationsOn;

  int get notificationTimeHour => userSettings.getNotificationTime.$1;
  int get notificationTimeMinute => userSettings.getNotificationTime.$2;

  String get notificationTimeDisplay {
    final (hour, minute) = userSettings.getNotificationTime;
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$hour:$paddedMinute';
  }

  Future<void> setNotifications(bool isOn) async {
    final service = getIt<NotificationService>();
    if (!isOn) {
      await userSettings.setNotifications(false);
      notifyListeners();
      await service.clearNotifications();
      return;
    }

    final isGranted = await service.requestNotificationPermission();
    if (isGranted) {
      await userSettings.setNotifications(true);
      notifyListeners();
      await service.scheduleNotifications();
    } else {
      await userSettings.setNotifications(false);
      notifyListeners();
    }
  }

  Future<void> setNotificationTime({
    required int hour,
    required int minute,
  }) async {
    await userSettings.setNotificationTime(hour: hour, minute: minute);
    notifyListeners();
    if (userSettings.isNotificationsOn) {
      final service = getIt<NotificationService>();
      await service.scheduleNotifications();
    }
  }

  bool get isBiblicalOrder => userSettings.isBiblicalOrder;

  Future<void> setIsBiblicalOrder(bool value) async {
    await userSettings.setIsBiblicalOrder(value);
    notifyListeners();
  }
}
