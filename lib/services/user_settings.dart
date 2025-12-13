import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static const defaultDailyLimit = 100000;
  static const defaultFixedGoodDays = 7;
  static const defaultFixedEasyDays = 30;

  static const String _themeModeKey = 'themeMode';
  static const String _dailyLimitKey = 'dailyLimit';
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

  ThemeMode get themeMode {
    final isDark = prefs.getBool(_themeModeKey);
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      await prefs.remove(_themeModeKey);
      return;
    }
    final isDark = mode == ThemeMode.dark;
    await prefs.setBool(_themeModeKey, isDark);
  }

  int get getDailyLimit {
    return prefs.getInt(_dailyLimitKey) ?? UserSettings.defaultDailyLimit;
  }

  Future<void> setDailyLimit(int value) async {
    await prefs.setInt(_dailyLimitKey, value);
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

  List<String> get pinnedCollections =>
      prefs.getStringList(_pinnedCollectionsKey) ?? [];

  Future<void> setPinnedCollections(List<String> ids) async {
    await prefs.setStringList(_pinnedCollectionsKey, ids);
  }

  DateTime? get lastLocalUpdate {
    final timestamp = prefs.getString(_lastLocalUpdateKey);
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }

  Future<void> setLastLocalUpdate([String? timestamp]) async {
    final dateTime = (timestamp != null)
        ? timestamp
        : DateTime.now().toUtc().toIso8601String();
    if (timestamp == null) {
      await prefs.remove(_lastLocalUpdateKey);
    }
    await prefs.setString(_lastLocalUpdateKey, dateTime);
  }

  int get getFixedGoodDays =>
      prefs.getInt(_fixedGoodDaysKey) ?? UserSettings.defaultFixedGoodDays;

  Future<void> setFixedGoodDays(int value) async {
    await prefs.setInt(_fixedGoodDaysKey, value);
  }

  int get getFixedEasyDays =>
      prefs.getInt(_fixedEasyDaysKey) ?? UserSettings.defaultFixedEasyDays;

  Future<void> setFixedEasyDays(int value) async {
    await prefs.setInt(_fixedEasyDaysKey, value);
  }

  int get getBrowserPreferredNumberOfColumns =>
      prefs.getInt(_browserColumnsKey) ?? 2;

  Future<void> setBrowserPreferredNumberOfColumns(int value) async {
    await prefs.setInt(_browserColumnsKey, value);
  }

  bool get isBiblicalOrder => prefs.getBool(_biblicalOrderKey) ?? false;

  Future<void> setIsBiblicalOrder(bool value) async {
    await prefs.setBool(_biblicalOrderKey, value);
  }
}
