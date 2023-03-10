import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:memorize_scripture/theme_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<ThemeManager>();
  final userSettings = getIt<UserSettings>();

  bool get shouldShowHints => _shouldShowHints;
  bool _shouldShowHints = true;

  bool get isDarkMode => _isDarkMode;
  bool _isDarkMode = false;

  Future<void> init() async {
    _shouldShowHints = await userSettings.getShowHints();
    _isDarkMode = await userSettings.getDarkMode();
    notifyListeners();
  }

  void setShowHints(bool value) {
    _shouldShowHints = value;
    userSettings.setShowHints(value);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    themeManager.setDarkTheme(value);
    userSettings.setDarkMode(value);
    notifyListeners();
  }
}
