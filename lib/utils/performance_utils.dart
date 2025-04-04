import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Classe per gestire le impostazioni di prestazioni dell'app
class PerformanceConfig {
  /// Preferenze salvate
  static SharedPreferences? _prefs;

  /// Chiavi per le preferenze
  static const String _keyParticlesEnabled = 'particles_enabled';
  static const String _keyParticlesCount = 'particles_count';
  static const String _keyAnimationsEnabled = 'animations_enabled';

  /// Valori predefiniti
  static const bool defaultParticlesEnabled = true;
  static const int defaultParticlesCount = 30;
  static const bool defaultAnimationsEnabled = true;

  /// Inizializza le preferenze
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ottiene se le particelle sono abilitate
  static bool get particlesEnabled =>
      _prefs?.getBool(_keyParticlesEnabled) ?? defaultParticlesEnabled;

  /// Imposta se le particelle sono abilitate
  static Future<void> setParticlesEnabled(bool enabled) async {
    await _prefs?.setBool(_keyParticlesEnabled, enabled);
  }

  /// Ottiene il numero di particelle
  static int get particlesCount =>
      _prefs?.getInt(_keyParticlesCount) ?? defaultParticlesCount;

  /// Imposta il numero di particelle
  static Future<void> setParticlesCount(int count) async {
    await _prefs?.setInt(_keyParticlesCount, count);
  }

  /// Ottiene se le animazioni sono abilitate
  static bool get animationsEnabled =>
      _prefs?.getBool(_keyAnimationsEnabled) ?? defaultAnimationsEnabled;

  /// Imposta se le animazioni sono abilitate
  static Future<void> setAnimationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyAnimationsEnabled, enabled);
  }

  /// Determina un numero appropriato di particelle basato sulla potenza del dispositivo
  static int getOptimalParticlesCount(BuildContext context) {
    // Determina la dimensione dello schermo
    final size = MediaQuery.of(context).size;
    final screenArea = size.width * size.height;

    // Dispositivi più piccoli = meno particelle
    if (screenArea < 250000) {
      return 15; // Dispositivi molto piccoli
    } else if (screenArea < 400000) {
      return 20; // Dispositivi piccoli
    } else if (screenArea < 600000) {
      return 25; // Dispositivi medi
    } else {
      return 30; // Dispositivi grandi
    }
  }
}
