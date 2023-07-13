import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<AppManager>();
  final userSettings = getIt<UserSettings>();

  bool get isDarkMode => userSettings.isDarkMode;

  int get dailyLimit => userSettings.getDailyLimit;

  bool get isTwoButtonMode => userSettings.isTwoButtonMode;

  Future<void> setDarkMode(bool value) async {
    themeManager.setDarkTheme(value);
    await userSettings.setDarkMode(value);
    notifyListeners();
  }

  Future<void> updateDailyLimit(int number) async {
    await userSettings.setDailyLimit(number);
    notifyListeners();
  }

  Future<void> setTwoButtonMode(bool value) async {
    await userSettings.setTwoButtonMode(value);
    notifyListeners();
  }

  int validateDailyLimit(String value) {
    int result = int.tryParse(value) ?? UserSettings.defaultDailyLimit;
    if (result < 0) return UserSettings.defaultDailyLimit;
    return result;
  }
}
