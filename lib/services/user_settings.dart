import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class UserSettings {
  static const defaultDailyLimit = 10;
  static const defaultMaxInterval = 100000;
  Future<void> init();
  bool get isTwoButtonMode;
  Future<void> setTwoButtonMode(bool value);
  bool get isDarkMode;
  Future<void> setDarkMode(bool value);
  int get getDailyLimit;
  Future<void> setDailyLimit(int value);
  int get getMaxInterval;
  Future<void> setMaxInterval(int value);
  bool get isNotificationsOn;
  Future<void> setNotifications(bool value);
  (int hour, int minute) get getNotificationTime;
  Future<void> setNotificationTime({required int hour, required int minute});
  (String? version, String? book, int? chapter) getRecentReference();
  Future<void> setRecentReference({
    required String? version,
    required String? book,
    required int? chapter,
  });
  int getChapterForBook(String book);
  Future<void> setChapterForBook(String book, int chapter);
  List<String> get pinnedCollections;
  Future<void> setPinnedCollections(List<String> ids);
  DateTime? get lastLocalUpdate;
  Future<void> setLastLocalUpdate(String? timestamp);
}

class SharedPreferencesStorage extends UserSettings {
  static const String _twoButtonModeKey = 'twoButtonMode';
  static const String _darkModeKey = 'darkMode';
  static const String _dailyLimitKey = 'dailyLimit';
  static const String _maxIntervalKey = 'maxInterval';
  static const String _notificationsKey = 'notifications';
  static const String _notificationTimeKey = 'notificationTime';
  static const String _recentReferenceKey = 'recentReference';
  static const String _pinnedCollectionsKey = 'pinnedCollections';
  static const String _lastLocalUpdateKey = 'lastLocalUpdateKey';

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
  int get getMaxInterval {
    return prefs.getInt(_maxIntervalKey) ?? UserSettings.defaultMaxInterval;
  }

  @override
  Future<void> setMaxInterval(int value) async {
    await prefs.setInt(_maxIntervalKey, value);
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

  @override
  (String? version, String? book, int? chapter) getRecentReference() {
    final json = prefs.getString(_recentReferenceKey);
    if (json == null) return (null, null, null);
    final map = jsonDecode(json);
    final version = map['version'];
    final book = map['book'];
    final chapter = map['chapter'];
    return (version, book, chapter);
  }

  @override
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
  @override
  int getChapterForBook(String book) {
    return prefs.getInt(book) ?? 1;
  }

  // The `book` is the key to save the chapter number.
  @override
  Future<void> setChapterForBook(String book, int chapter) async {
    await prefs.setInt(book, chapter);
  }

  @override
  List<String> get pinnedCollections =>
      prefs.getStringList(_pinnedCollectionsKey) ?? [];

  @override
  Future<void> setPinnedCollections(List<String> ids) async {
    await prefs.setStringList(_pinnedCollectionsKey, ids);
  }

  @override
  DateTime? get lastLocalUpdate {
    final timestamp = prefs.getString(_lastLocalUpdateKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  @override
  Future<void> setLastLocalUpdate(String? timestamp) {
    if (timestamp == null) {
      return prefs.remove(_lastLocalUpdateKey);
    }
    return prefs.setString(_lastLocalUpdateKey, timestamp);
  }
}
