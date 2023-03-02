import 'package:flutter/material.dart';

class ThemeManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);

  var isDarkListener = ValueNotifier<bool>(false);

  // get isDark => _isDark;

  // bool _isDark = false;

  void toggleTheme() {
    final isDark = isDarkListener.value;
    themeListener.value = (isDark) ? _lightTheme : _darkTheme;
    isDarkListener.value = !isDark;
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.lightBlue.shade800,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.light().disabledColor),
  ),
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.lightBlue.shade800,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.dark().disabledColor),
  ),
);
