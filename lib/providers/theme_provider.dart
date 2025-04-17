import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  double _textScaleFactor = 1.0;
  bool _isMusicEnabled = true;

  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;
  bool get isMusicEnabled => _isMusicEnabled;

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
    _isMusicEnabled = prefs.getBool('isMusicEnabled') ?? true;

    // Sincronizza lo stato della musica con il servizio audio
    AudioService().setMusicEnabled(_isMusicEnabled);

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

  // Attiva/disattiva la musica di sottofondo
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;

    // Aggiorna il servizio audio
    AudioService().setMusicEnabled(_isMusicEnabled);

    _savePreferences();
    notifyListeners();
  }

  // Imposta lo stato della musica
  void setMusicEnabled(bool value) {
    _isMusicEnabled = value;

    // Aggiorna il servizio audio
    AudioService().setMusicEnabled(_isMusicEnabled);

    _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('textScaleFactor', _textScaleFactor);
    await prefs.setBool('isMusicEnabled', _isMusicEnabled);
  }
}
