import 'package:flutter/material.dart';

/// App theme configuration
/// Provides normal and high contrast themes for accessibility
class AppTheme {
  // Brand colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);

  // Normal theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(120, 48),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  // High contrast theme for visually impaired
  static ThemeData highContrastTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.yellow,
      onPrimary: Colors.black,
      secondary: Colors.yellow,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.black,
      onSurface: Colors.yellow,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.yellow,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.yellow, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.yellow, width: 2),
        ),
        minimumSize: const Size(140, 56),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.yellow, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.yellow, fontSize: 16),
      titleLarge: TextStyle(color: Colors.yellow, fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.yellow, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.yellow, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.yellow, width: 3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      labelStyle: const TextStyle(color: Colors.yellow, fontSize: 18),
      hintStyle: TextStyle(color: Colors.yellow.withValues(alpha: 0.7)),
    ),
  );

  // Text scale factors for accessibility
  static const double normalTextScale = 1.0;
  static const double largeTextScale = 1.5;
  static const double extraLargeTextScale = 2.0;
}
