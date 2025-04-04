import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// Servizio per gestire gli annunci pubblicitari
class AdService {
  /// Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isInitialized = false;

  /// ID per gli annunci a schermo intero
  static const String _interstitialAdUnitIdAndroid =
      'ca-app-pub-2270953481573275/3408502205';
  static const String _interstitialAdUnitIdIOS =
      'ca-app-pub-3940256099942544/4411468910';

  /// Ottiene l'ID dell'annuncio a schermo intero in base alla piattaforma
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _interstitialAdUnitIdIOS;
    } else {
      // Fallback su Android se la piattaforma non è riconosciuta
      return _interstitialAdUnitIdAndroid;
    }
  }

  /// Inizializza il servizio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Inizializzazione AdMob in corso...');
      // Configurazione per testare su emulatore
      if (kDebugMode) {
        final testDeviceIds = [
          'ABCDEF123456',
        ]; // Puoi aggiungere l'ID del tuo dispositivo qui
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDeviceIds),
        );
        debugPrint(
          '🛠️ AdMob configurato per test su emulatore con ID dispositivi: $testDeviceIds',
        );
      }

      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('✅ AdMob inizializzato con successo');
      debugPrint('🔄 Caricamento del primo annuncio interstiziale...');
      loadInterstitialAd();
    } catch (e) {
      debugPrint('❌ Errore nell\'inizializzazione di AdMob: $e');
    }
  }

  /// Carica un annuncio a schermo intero
  void loadInterstitialAd() {
    debugPrint('📱 Caricamento annuncio con ID: $interstitialAdUnitId');

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          // Configura un listener per ricaricare l'annuncio quando viene chiuso
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('⏱️ Annuncio interstiziale chiuso dall\'utente');
              _isInterstitialAdReady = false;
              ad.dispose();
              loadInterstitialAd(); // Ricarica un nuovo annuncio
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                '❌ Errore nella visualizzazione dell\'annuncio: ${error.message}',
              );
              _isInterstitialAdReady = false;
              ad.dispose();
              loadInterstitialAd(); // Ricarica un nuovo annuncio
            },
            onAdShowedFullScreenContent: (ad) {
              debugPrint(
                '👁️ Annuncio interstiziale visualizzato a schermo intero',
              );
            },
            onAdImpression: (ad) {
              debugPrint('👁️ Impression dell\'annuncio registrata');
            },
          );

          debugPrint('✅ Annuncio interstiziale caricato con successo');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          debugPrint(
            '❌ Errore nel caricamento dell\'annuncio: ${error.message} (Codice: ${error.code})',
          );

          // Riprova a caricare dopo un ritardo
          debugPrint('🔄 Nuovo tentativo di caricamento tra 1 minuto');
          Future.delayed(const Duration(minutes: 1), loadInterstitialAd);
        },
      ),
    );
  }

  /// Mostra un annuncio a schermo intero se disponibile
  Future<void> showInterstitialAd() async {
    if (!_isInitialized) {
      debugPrint(
        '🚀 Inizializzazione AdMob richiesta prima di mostrare l\'annuncio',
      );
      await initialize();
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      debugPrint('📱 Visualizzazione annuncio interstiziale...');
      await _interstitialAd!.show();
      _isInterstitialAdReady = false;
      return;
    }

    // Se l'annuncio non è pronto, ricaricalo
    debugPrint('⚠️ Annuncio non disponibile per la visualizzazione');
    loadInterstitialAd();
    debugPrint('🔄 Ricaricamento annuncio in corso');
  }

  /// Rilascia le risorse quando non più necessarie
  void dispose() {
    debugPrint('🧹 Pulizia risorse AdMob');
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
