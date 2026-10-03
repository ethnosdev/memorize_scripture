import 'package:flutter/material.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';

class AppManager {
  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final fontSizeNotifier = ValueNotifier<double>(UserSettings.defaultFontSize);
  final userSettings = getIt<UserSettings>();

  Future<void> init() async {
    await userSettings.init();
    themeNotifier.value = userSettings.themeMode;
    fontSizeNotifier.value = userSettings.fontSize;
    await getIt<LocalStorage>().init();
    try {
      final notificationService = getIt<NotificationService>();
      await notificationService.init();
      await notificationService.scheduleNotifications();
    } catch (e, stack) {
      debugPrint('Error initializing notifications: $e\n$stack');
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeNotifier.value = mode;
  }

  void setFontSize(double size) {
    fontSizeNotifier.value = size;
  }

  double get fontSize => fontSizeNotifier.value;

  double scaledFontSize([double scaleFactor = 1.0]) => fontSize * scaleFactor;

  static ThemeData lightTheme([double fontSize = UserSettings.defaultFontSize]) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.yellow,
    );
    final scale = fontSize / UserSettings.defaultFontSize;
    return base.copyWith(
      textTheme: _scaleTextTheme(base.textTheme, scale),
    );
  }

  static ThemeData darkTheme([double fontSize = UserSettings.defaultFontSize]) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.yellow,
      brightness: Brightness.dark,
    );
    final scale = fontSize / UserSettings.defaultFontSize;
    return base.copyWith(
      textTheme: _scaleTextTheme(base.textTheme, scale),
    );
  }

  static TextTheme _scaleTextTheme(TextTheme textTheme, double scale) {
    if (scale == 1.0) return textTheme;
    TextStyle? scaleStyle(TextStyle? style, double defaultSize) {
      if (style == null) return TextStyle(fontSize: defaultSize * scale);
      return style.copyWith(fontSize: (style.fontSize ?? defaultSize) * scale);
    }

    return textTheme.copyWith(
      displayLarge: scaleStyle(textTheme.displayLarge, 57),
      displayMedium: scaleStyle(textTheme.displayMedium, 45),
      displaySmall: scaleStyle(textTheme.displaySmall, 36),
      headlineLarge: scaleStyle(textTheme.headlineLarge, 32),
      headlineMedium: scaleStyle(textTheme.headlineMedium, 28),
      headlineSmall: scaleStyle(textTheme.headlineSmall, 24),
      titleLarge: scaleStyle(textTheme.titleLarge, 22),
      titleMedium: scaleStyle(textTheme.titleMedium, 16),
      titleSmall: scaleStyle(textTheme.titleSmall, 14),
      bodyLarge: scaleStyle(textTheme.bodyLarge, 16),
      bodyMedium: scaleStyle(textTheme.bodyMedium, 14),
      bodySmall: scaleStyle(textTheme.bodySmall, 12),
    );
  }
}
