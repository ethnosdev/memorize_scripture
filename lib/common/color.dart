// http://mcg.mbitson.com

import 'package:flutter/material.dart';

const MaterialColor customYellow =
    MaterialColor(_yellowPrimaryValue, <int, Color>{
  50: Color(0xFFFFFAE1),
  100: Color(0xFFFEF2B4),
  200: Color(0xFFFDEA82),
  300: Color(0xFFFCE250),
  400: Color(0xFFFCDB2B),
  500: Color(_yellowPrimaryValue),
  600: Color(0xFFFAD004),
  700: Color(0xFFFACA04),
  800: Color(0xFFF9C403),
  900: Color(0xFFF8BA01),
});
const int _yellowPrimaryValue = 0xFFFBD505;

const MaterialColor customYellowAccent =
    MaterialColor(_yellowAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_yellowAccentValue),
  400: Color(0xFFFFEBB8),
  700: Color(0xFFFFE49F),
});
const int _yellowAccentValue = 0xFFFFF9EB;
