import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const _kThemeKey = 'app_theme_id';
  static const _kDarkKey = 'app_theme_dark';

  AppThemeId _themeId = AppThemeId.eco;
  bool _dark = false;

  AppThemeId get themeId => _themeId;
  bool get isDark => _dark;
  ThemeData get theme => AppTheme.themeOf(_themeId, dark: _dark);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_kThemeKey);
    final d = prefs.getBool(_kDarkKey);
    if (idx != null && idx >= 0 && idx < AppThemeId.values.length) {
      _themeId = AppThemeId.values[idx];
    }
    _dark = d ?? false;
    notifyListeners();
  }

  Future<void> setTheme(AppThemeId id) async {
    _themeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeKey, id.index);
    notifyListeners();
  }

  Future<void> toggleDarkMode([bool? value]) async {
    _dark = value ?? !_dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkKey, _dark);
    notifyListeners();
  }
}
