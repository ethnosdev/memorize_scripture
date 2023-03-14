import 'package:flutter/foundation.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/theme_manager.dart';

class SettingsPageManager extends ChangeNotifier {
  final themeManager = getIt<ThemeManager>();

  bool get shouldShowHints => _shouldShowHints;
  bool _shouldShowHints = false;

  bool get isDarkMode => _isDarkMode;
  bool _isDarkMode = false;

  void setShowHints(bool value) {
    _shouldShowHints = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    print(value);
    themeManager.setDarkTheme(value);
    notifyListeners();
  }
}
