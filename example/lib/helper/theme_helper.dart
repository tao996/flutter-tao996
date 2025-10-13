
import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class ThemeHelper extends ThemeService {
  @override
  ThemeData buildDarkTheme(ColorScheme? dynamicDart) {
    return ThemeData(brightness: Brightness.dark, useMaterial3: true);
  }

  @override
  ThemeData buildLightTheme(ColorScheme? dynamicLight) {
    // final ColorScheme customColorScheme = ColorScheme.fromSeed(
    //   seedColor: Colors.deepPurple,
    // );
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      // colorScheme: customColorScheme,
    );
  }

  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}