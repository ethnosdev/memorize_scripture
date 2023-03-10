import 'package:flutter/material.dart';

class ThemeManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);

  var isDarkListener = ValueNotifier<bool>(false);

  void toggleTheme() {
    final isDark = isDarkListener.value;
    themeListener.value = (isDark) ? _lightTheme : _darkTheme;
    isDarkListener.value = !isDark;
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
