import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static const defaultDailyLimit = 100000;
  static const defaultFixedGoodDays = 7;
  static const defaultFixedEasyDays = 30;

  static const String _darkModeKey = 'darkMode';
  static const String _dailyLimitKey = 'dailyLimit';
  static const String _notificationsKey = 'notifications';
  static const String _notificationTimeKey = 'notificationTime';
  static const String _recentReferenceKey = 'recentReference';
  static const String _pinnedCollectionsKey = 'pinnedCollections';
  static const String _lastLocalUpdateKey = 'lastLocalUpdateKey';
  static const String _fixedGoodDaysKey = 'fixedGoodDaysKey';
  static const String _fixedEasyDaysKey = 'fixedEasyDaysKey';
  static const String _browserColumnsKey = 'browserColumnsKey';
  static const String _biblicalOrderKey = 'biblicalOrderKey';

  // getters cache
  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool get isDarkMode => prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) async {
    await prefs.setBool(_darkModeKey, value);
  }

  int get getDailyLimit {
    return prefs.getInt(_dailyLimitKey) ?? UserSettings.defaultDailyLimit;
  }

  Future<void> setDailyLimit(int value) async {
    await prefs.setInt(_dailyLimitKey, value);
  }

  bool get isNotificationsOn => prefs.getBool(_notificationsKey) ?? false;

  Future<void> setNotifications(bool value) async {
    await prefs.setBool(_notificationsKey, value);
  }

  (int, int) get getNotificationTime {
    final hourMinute = prefs.getString(_notificationTimeKey) ?? '20:00';
    final parts = hourMinute.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return (20, 0);
    return (hour, minute);
  }

  Future<void> setNotificationTime({
    required int hour,
    required int minute,
  }) async {
    final value = '$hour:$minute';
    await prefs.setString(_notificationTimeKey, value);
  }

  (String? version, String? book, int? chapter) getRecentReference() {
    final json = prefs.getString(_recentReferenceKey);
    if (json == null) return (null, null, null);
    final map = jsonDecode(json);
    final version = map['version'];
    final book = map['book'];
    final chapter = map['chapter'];
    return (version, book, chapter);
  }

  Future<void> setRecentReference({
    required String? version,
    required String? book,
    required int? chapter,
  }) async {
    final map = {
      'version': version,
      'book': book,
      'chapter': chapter,
    };
    final json = jsonEncode(map);
    await prefs.setString(_recentReferenceKey, json);
  }

  // The `book` is its own key.
  int getChapterForBook(String book) {
    return prefs.getInt(book) ?? 1;
  }

  // The `book` is the key to save the chapter number.
  Future<void> setChapterForBook(String book, int chapter) async {
    await prefs.setInt(book, chapter);
  }

  List<String> get pinnedCollections => prefs.getStringList(_pinnedCollectionsKey) ?? [];

  Future<void> setPinnedCollections(List<String> ids) async {
    await prefs.setStringList(_pinnedCollectionsKey, ids);
  }

  DateTime? get lastLocalUpdate {
    final timestamp = prefs.getString(_lastLocalUpdateKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<void> setLastLocalUpdate([String? timestamp]) async {
    final dateTime = (timestamp != null) ? timestamp : DateTime.now().toUtc().toIso8601String();
    if (timestamp == null) {
      await prefs.remove(_lastLocalUpdateKey);
    }
    await prefs.setString(_lastLocalUpdateKey, dateTime);
  }

  int get getFixedGoodDays => prefs.getInt(_fixedGoodDaysKey) ?? UserSettings.defaultFixedGoodDays;

  Future<void> setFixedGoodDays(int value) async {
    await prefs.setInt(_fixedGoodDaysKey, value);
  }

  int get getFixedEasyDays => prefs.getInt(_fixedEasyDaysKey) ?? UserSettings.defaultFixedEasyDays;

  Future<void> setFixedEasyDays(int value) async {
    await prefs.setInt(_fixedEasyDaysKey, value);
  }

  int get getBrowserPreferredNumberOfColumns => prefs.getInt(_browserColumnsKey) ?? 2;

  Future<void> setBrowserPreferredNumberOfColumns(int value) async {
    await prefs.setInt(_browserColumnsKey, value);
  }

  bool get isBiblicalOrder => prefs.getBool(_biblicalOrderKey) ?? false;

  Future<void> setIsBiblicalOrder(bool value) async {
    await prefs.setBool(_biblicalOrderKey, value);
  }
}
