import 'package:shared_preferences/shared_preferences.dart';

abstract class UserSettings {
  static const defaultDailyLimit = 10;

  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  Future<int> getDailyLimit();
  Future<void> setDailyLimit(int value);
}

class SharedPreferencesStorage extends UserSettings {
  static const String _darkModeKey = 'darkMode';
  static const String _dailyLimitKey = 'dailyLimit';

  @override
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  @override
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  @override
  Future<int> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyLimitKey) ?? UserSettings.defaultDailyLimit;
  }

  @override
  Future<void> setDailyLimit(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyLimitKey, value);
  }
}
