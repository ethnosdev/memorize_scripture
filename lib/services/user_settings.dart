import 'package:shared_preferences/shared_preferences.dart';

abstract class UserSettings {
  static const defaultDailyLimit = 10;
  Future<void> init();
  bool get isTwoButtonMode;
  Future<void> setTwoButtonMode(bool value);
  bool get isDarkMode;
  Future<void> setDarkMode(bool value);
  int get getDailyLimit;
  Future<void> setDailyLimit(int value);
  bool get isNotificationsOn;
  Future<void> setNotifications(bool value);
  (int hour, int minute) get getNotificationTime;
  Future<void> setNotificationTime({required int hour, required int minute});
}

class SharedPreferencesStorage extends UserSettings {
  static const String _twoButtonModeKey = 'twoButtonMode';
  static const String _darkModeKey = 'darkMode';
  static const String _dailyLimitKey = 'dailyLimit';
  static const String _notificationsKey = 'notifications';
  static const String _notificationTimeKey = 'notificationTime';

  // getters cache
  late final SharedPreferences prefs;

  @override
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  bool get isTwoButtonMode => prefs.getBool(_twoButtonModeKey) ?? false;

  @override
  Future<void> setTwoButtonMode(bool value) async {
    await prefs.setBool(_twoButtonModeKey, value);
  }

  @override
  bool get isDarkMode => prefs.getBool(_darkModeKey) ?? false;

  @override
  Future<void> setDarkMode(bool value) async {
    await prefs.setBool(_darkModeKey, value);
  }

  @override
  int get getDailyLimit {
    return prefs.getInt(_dailyLimitKey) ?? UserSettings.defaultDailyLimit;
  }

  @override
  Future<void> setDailyLimit(int value) async {
    await prefs.setInt(_dailyLimitKey, value);
  }

  @override
  bool get isNotificationsOn => prefs.getBool(_notificationsKey) ?? false;

  @override
  Future<void> setNotifications(bool value) async {
    await prefs.setBool(_notificationsKey, value);
  }

  @override
  (int, int) get getNotificationTime {
    final hourMinute = prefs.getString(_notificationTimeKey) ?? '20:00';
    final parts = hourMinute.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return (20, 0);
    return (hour, minute);
  }

  @override
  Future<void> setNotificationTime({
    required int hour,
    required int minute,
  }) async {
    final value = '$hour:$minute';
    await prefs.setString(_notificationTimeKey, value);
  }
}
