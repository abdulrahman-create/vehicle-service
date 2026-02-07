import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme preference key
const String _themePreferenceKey = 'theme_mode';

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _loadThemePreference();
  }

  // Load theme preference from storage
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themePreferenceKey);

    if (themeModeString != null) {
      switch (themeModeString) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
          state = ThemeMode.system;
          break;
      }
    }
  }

  // Save theme preference to storage
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString;

    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await prefs.setString(_themePreferenceKey, themeModeString);
  }

  // Set theme and save preference
  void setTheme(ThemeMode mode) {
    state = mode;
    _saveThemePreference(mode);
  }
}
