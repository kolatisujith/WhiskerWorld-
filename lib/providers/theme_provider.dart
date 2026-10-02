import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing and persisting Light / Dark / System theme preference
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'whisker_theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode != null) {
        if (savedMode == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedMode == 'light') {
          _themeMode = ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (_) {
      // Fallback to light mode silently if prefs unavailable
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'light';
      if (mode == ThemeMode.dark) val = 'dark';
      if (mode == ThemeMode.system) val = 'system';
      await prefs.setString(_prefKey, val);
    } catch (_) {
      // Ignore prefs error
    }
  }
}
