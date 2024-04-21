import 'package:flutter/material.dart';
import 'package:myproject/src/utils/theme/widget_theme/text_theme.dart';

class AppTheme{
  AppTheme._();
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
    textTheme:TextThemee.lightTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom())
  );
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
    textTheme: TextThemee.darkTextTheme,
  );
}