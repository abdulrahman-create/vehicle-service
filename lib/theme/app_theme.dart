import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E7CF6),
      secondary: Color(0xFF4CAF50),
      surface: Colors.white,
      error: Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1F28),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7CF6),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2E7CF6),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2E7CF6), width: 2),
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4D9FFF),
      secondary: Color(0xFF66BB6A),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFEF5350),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4D9FFF),
      foregroundColor: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4D9FFF), width: 2),
      ),
    ),
  );
}
