import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  double _textScaleFactor = 1.0;

  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;

  ThemeData get themeData =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  ThemeProvider() {
    _loadPreferences();
  }

  // Carica le preferenze salvate
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    notifyListeners();
  }

  // Cambia il tema (chiaro/scuro)
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  // Imposta una scala specifica per il testo
  void setTextScaleFactor(double value) {
    _textScaleFactor = value;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('textScaleFactor', _textScaleFactor);
  }
}
