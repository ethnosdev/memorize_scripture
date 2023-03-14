import 'package:flutter/material.dart';

class ThemeManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);

  void setDarkTheme(bool isDark) {
    themeListener.value = (isDark) ? _darkTheme : _lightTheme;
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.light().disabledColor),
  ),
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(fontSize: 14),
    labelSmall: TextStyle(color: ThemeData.dark().disabledColor),
  ),
);
