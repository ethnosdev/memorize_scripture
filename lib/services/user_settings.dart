import 'package:shared_preferences/shared_preferences.dart';

abstract class UserSettings {
  Future<bool> getShowHints();
  Future<void> setShowHints(bool value);
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
}

class SharedPreferencesLocalStorage extends UserSettings {
  static const String _showHintsKey = 'showHints';
  static const String _darkModeKey = 'darkMode';

  @override
  Future<bool> getShowHints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showHintsKey) ?? true;
  }

  @override
  Future<void> setShowHints(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showHintsKey, value);
  }

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
}
