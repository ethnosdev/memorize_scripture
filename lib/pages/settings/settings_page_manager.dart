import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<AppManager>();
  final userSettings = getIt<UserSettings>();
  // final dailyLimitNotifier = ValueNotifier<int>(1);

  bool get isDarkMode => _isDarkMode;
  bool _isDarkMode = false;

  int get dailyLimit => _dailyLimit;
  int _dailyLimit = 1;

  Future<void> init() async {
    _isDarkMode = await userSettings.getDarkMode();
    _dailyLimit = await userSettings.getDailyLimit();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    themeManager.setDarkTheme(value);
    userSettings.setDarkMode(value);
    notifyListeners();
  }

  void updateDailyLimit(int number) {
    _dailyLimit = number;
    userSettings.setDailyLimit(number);
    notifyListeners();
  }

  int validateDailyLimit(String value) {
    int result = int.tryParse(value) ?? 1;
    if (result < 0) return 1;
    return result;
  }
}
