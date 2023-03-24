import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/app_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<AppManager>();
  final userSettings = getIt<UserSettings>();

  bool get isDarkMode => _isDarkMode;
  bool _isDarkMode = false;

  Future<void> init() async {
    _isDarkMode = await userSettings.getDarkMode();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    themeManager.setDarkTheme(value);
    userSettings.setDarkMode(value);
    notifyListeners();
  }
}
