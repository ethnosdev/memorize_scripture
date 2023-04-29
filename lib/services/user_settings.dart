import 'package:shared_preferences/shared_preferences.dart';

abstract class UserSettings {
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool value);
  // Future<int?> getBuildNumber();
  // Future<void> setBuildNumber(int buildNumber);
  Future<int?> getNewVerseFrequency();
  Future<void> setNewVerseFrequency(int frequency);
}

class SharedPreferencesStorage extends UserSettings {
  static const String _darkModeKey = 'darkMode';
  // static const String _buildNumberKey = 'buildNumber';
  static const String _newVerseFrequencyKey = 'newVerseFrequency';

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

  // @override
  // Future<int?> getBuildNumber() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getInt(_buildNumberKey);
  // }

  // @override
  // Future<void> setBuildNumber(int buildNumber) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt(_buildNumberKey, buildNumber);
  // }

  @override
  Future<int?> getNewVerseFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_newVerseFrequencyKey);
  }

  @override
  Future<void> setNewVerseFrequency(int frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_newVerseFrequencyKey, frequency);
  }
}
