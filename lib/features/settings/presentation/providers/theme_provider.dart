import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required SharedPreferences preferences})
      : _preferences = preferences,
        _themeMode = _readThemeMode(preferences);

  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _preferences.setString(_themeModeKey, mode.name);
  }

  static ThemeMode _readThemeMode(SharedPreferences preferences) {
    final value = preferences.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
