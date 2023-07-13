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
}

class SharedPreferencesStorage extends UserSettings {
  static const String _twoButtonModeKey = 'twoButtonMode';
  static const String _darkModeKey = 'darkMode';
  static const String _dailyLimitKey = 'dailyLimit';

  // getters cache
  late final SharedPreferences prefs;

  @override
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  bool get isTwoButtonMode => prefs.getBool(_twoButtonModeKey) ?? true;

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
}
