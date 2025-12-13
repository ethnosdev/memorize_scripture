import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
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

  bool get isBiblicalOrder => userSettings.isBiblicalOrder;

  Future<void> setIsBiblicalOrder(bool value) async {
    await userSettings.setIsBiblicalOrder(value);
    notifyListeners();
  }
}
