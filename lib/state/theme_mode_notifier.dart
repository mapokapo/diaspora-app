import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode? _themeMode;
  ThemeMode get themeMode => _themeMode ?? ThemeMode.system;

  ThemeModeNotifier(String? storedThemeMode) {
    _themeMode = storedThemeMode == null
        ? null
        : !ThemeMode.values.any((t) => t.toString() == storedThemeMode)
            ? null
            : ThemeMode.values
                .singleWhere((t) => t.toString() == storedThemeMode);
  }

  void setThemeMode(ThemeMode? newThemeMode) async {
    var prefs = await SharedPreferences.getInstance();
    if (newThemeMode == null) {
      await prefs.remove('themeMode');
    } else {
      await prefs.setString('themeMode', newThemeMode.toString());
    }
    _themeMode = newThemeMode;
    notifyListeners();
  }

  void toggleThemeMode() {
    setThemeMode(
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
