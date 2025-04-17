import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Servizio per la gestione degli annunci AdMob
class AdService {
  /// Singleton pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  /// Flag per tenere traccia se gli annunci sono stati inizializzati
  bool _isInitialized = false;

  /// Annuncio interstiziale
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  /// Contatore per i tentativi di caricamento
  int _loadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  /// ID degli annunci per Android/iOS
  final String _interstitialAdUnitId =
      // Durante lo sviluppo usiamo sempre ID di test per evitare problemi
      kDebugMode
          ? 'ca-app-pub-3940256099942544/1033173712' // ID di test
          : Platform.isAndroid
          ? 'ca-app-pub-2270953481573275/3408502205' // ID reale Android dell'utente
          : 'ca-app-pub-2270953481573275/8019791981'; // ID reale iOS dell'utente

  /// Lista dei dispositivi di test (se vuoti, non vengono utilizzati)
  final List<String> testDeviceIds = [
    'ABCDEF012345', // Esempio ID dispositivo di test (sostituire con ID reali se necessario)
    '98765432FEDCBA', // Esempio ID dispositivo di test
  ];

  /// Inizializza il servizio
  Future<void> initialize() async {
    // Su web, non inizializziamo AdMob
    if (kIsWeb) {
      debugPrint('🌐 AdService: Web non supportato, annunci disabilitati');
      return;
    }

    if (_isInitialized) return;

    try {
      // Configura i dispositivi di test in modalità debug
      if (kDebugMode) {
        debugPrint('🧪 Inizializzazione in modalità TEST');
        RequestConfiguration configuration = RequestConfiguration(
          testDeviceIds: testDeviceIds.isNotEmpty ? testDeviceIds : null,
        );
        await MobileAds.instance.updateRequestConfiguration(configuration);
      }

      // Carica un annuncio interstiziale immediatamente
      await _loadInterstitialAd();

      // Imposta un timer per verificare periodicamente lo stato dell'annuncio e caricarne uno nuovo se necessario
      Timer.periodic(const Duration(minutes: 1), (timer) {
        if (_interstitialAd == null && !_isInterstitialAdLoading) {
          debugPrint('🔄 Timer: Ricarico annuncio interstiziale');
          _loadInterstitialAd();
        }
      });

      _isInitialized = true;
      debugPrint('✅ AdService inizializzato con successo');
      if (kDebugMode) {
        debugPrint('🧪 Usando ID annuncio di TEST: $_interstitialAdUnitId');
      } else {
        debugPrint('🚀 Usando ID annuncio REALE: $_interstitialAdUnitId');
      }
    } catch (e) {
      debugPrint('❌ Errore nell\'inizializzazione di AdService: $e');
    }
  }

  /// Carica un annuncio interstiziale
  Future<void> _loadInterstitialAd() async {
    if (kIsWeb) return;
    if (_isInterstitialAdLoading) return;
    if (_loadAttempts >= maxFailedLoadAttempts) {
      debugPrint('⚠️ Raggiunto il numero massimo di tentativi di caricamento');
      // Reset del contatore dopo un po' di tempo
      Future.delayed(const Duration(minutes: 5), () {
        _loadAttempts = 0;
        _loadInterstitialAd();
      });
      return;
    }

    try {
      _isInterstitialAdLoading = true;
      debugPrint('🔄 Inizio caricamento annuncio interstiziale');

      // Configurazione della richiesta di annuncio
      final AdRequest request = AdRequest(
        // Se sei in modalità debugging, quando hai problemi con gli annunci
        // puoi provare ad attivare questo flag per fornire più informazioni di debug
        nonPersonalizedAds: true,
      );

      // Log dei parametri di richiesta per debug
      debugPrint('📊 Parametri richiesta annuncio:');
      debugPrint('   - AdUnit ID: $_interstitialAdUnitId');
      debugPrint('   - Piattaforma: ${Platform.isAndroid ? 'Android' : 'iOS'}');

      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
            _loadAttempts = 0; // Reset del contatore dei tentativi
            debugPrint('✅ Annuncio interstiziale caricato con successo');

            // Imposta i callback per l'annuncio
            _interstitialAd!
                .fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('🚪 Annuncio interstiziale chiuso');
                ad.dispose();
                _interstitialAd = null;
                // Carica immediatamente un nuovo annuncio
                _loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint(
                  '⚠️ Errore nella visualizzazione dell\'annuncio: $error',
                );
                ad.dispose();
                _interstitialAd = null;
                _loadAttempts++;
                // Prova a ricaricare dopo un breve ritardo
                Future.delayed(const Duration(seconds: 1), () {
                  _loadInterstitialAd();
                });
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('🎬 Annuncio interstiziale mostrato');
              },
              onAdClicked: (ad) {
                debugPrint('👆 Annuncio cliccato dall\'utente');
              },
              onAdImpression: (ad) {
                debugPrint('👁️ Impressione dell\'annuncio registrata');
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint(
              '⚠️ Errore nel caricamento dell\'annuncio: ${error.code}:${error.message}',
            );

            // Informazioni dettagliate sull'errore per il debug
            debugPrint('   - Codice errore: ${error.code}');
            debugPrint('   - Dominio errore: ${error.domain}');
            debugPrint('   - Messaggio: ${error.message}');

            _interstitialAd = null;
            _isInterstitialAdLoading = false;
            _loadAttempts++;

            if (_loadAttempts < maxFailedLoadAttempts) {
              // Riprova a caricare l'annuncio dopo un ritardo crescente
              int delaySeconds = (_loadAttempts * 5).clamp(1, 30);
              debugPrint(
                '🔄 Riprovo a caricare l\'annuncio tra $delaySeconds secondi (tentativo ${_loadAttempts}/$maxFailedLoadAttempts)',
              );
              Future.delayed(Duration(seconds: delaySeconds), () {
                _loadInterstitialAd();
              });
            } else {
              // Se raggiungiamo il numero massimo di tentativi, attendiamo più a lungo
              debugPrint('⚠️ Troppe richieste fallite, attendiamo più a lungo');
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Eccezione nel caricamento dell\'annuncio: $e');
      _isInterstitialAdLoading = false;
      _loadAttempts++;
      // Riprova dopo un breve ritardo
      Future.delayed(const Duration(seconds: 5), () {
        _loadInterstitialAd();
      });
    }
  }

  /// Mostra un annuncio interstiziale e restituisce true se l'annuncio è stato mostrato
  Future<bool> showInterstitialAd() async {
    if (kIsWeb) {
      debugPrint('🌐 AdService: Web non supportato, annuncio non mostrato');
      return false;
    }

    debugPrint(
      '🔍 Richiesta di mostrare annuncio: annuncio disponibile = ${_interstitialAd != null}, caricamento in corso = $_isInterstitialAdLoading',
    );

    // Prima forziamo un precaricamento completo dell'annuncio se non è disponibile
    if (_interstitialAd == null) {
      debugPrint('🔄 Annuncio non disponibile, avvio caricamento forzato');

      // Se c'è già un caricamento in corso, cancelliamo il flag per forzarne uno nuovo
      if (_isInterstitialAdLoading) {
        debugPrint(
          '⚠️ Caricamento già in corso, lo interrompo e ne avvio uno nuovo',
        );
        _isInterstitialAdLoading = false;
      }

      // Azzeriamo i tentativi per ripartire da zero
      _loadAttempts = 0;

      // Avviamo un nuovo caricamento
      await _loadInterstitialAd();

      // Attendi più a lungo per il caricamento dell'annuncio
      debugPrint(
        '⏳ Attendo il caricamento dell\'annuncio con timeout esteso...',
      );
      int waitTimeMs = 0;
      const maxWaitTimeMs = 5000; // 5 secondi di attesa massima (aumentato)
      const checkIntervalMs = 200; // Controlla ogni 200ms

      while (_isInterstitialAdLoading && waitTimeMs < maxWaitTimeMs) {
        await Future.delayed(const Duration(milliseconds: checkIntervalMs));
        waitTimeMs += checkIntervalMs;
        debugPrint('⌛ Attesa in corso... ${waitTimeMs}ms/${maxWaitTimeMs}ms');
      }

      debugPrint('⏱️ Atteso $waitTimeMs ms per il caricamento dell\'annuncio');

      // Verifichiamo se l'annuncio è disponibile dopo l'attesa
      if (_interstitialAd == null) {
        // Se dopo l'attesa ancora non è disponibile, proviamo ad attivare la modalità di test
        debugPrint(
          '⚠️ Dopo l\'attesa estesa, l\'annuncio non è ancora disponibile',
        );
        debugPrint('ℹ️ Informazioni per debug:');
        debugPrint('   - ID annuncio: $_interstitialAdUnitId');
        debugPrint('   - Tentativi di caricamento: $_loadAttempts');
        debugPrint(
          '   - Piattaforma: ${Platform.isAndroid ? 'Android' : 'iOS'}',
        );

        // Verifichiamo se Google Mobile Ads SDK è correttamente inizializzato
        debugPrint('🔍 Verificando l\'inizializzazione di AdMob...');

        // Suggerimento all'utente
        debugPrint(
          '💡 Suggerimento: Potrebbe essere necessario verificare la connessione di rete o controllare che l\'account AdMob sia correttamente configurato',
        );

        // Riavvia il caricamento per il prossimo tentativo
        Future.delayed(const Duration(seconds: 1), () {
          _loadInterstitialAd();
        });

        return false;
      }
    }

    // Se abbiamo un annuncio pronto, lo mostriamo
    if (_interstitialAd != null) {
      try {
        debugPrint('🎯 Annuncio disponibile, tentativo di visualizzazione...');
        await _interstitialAd!.show();
        debugPrint('✅ Annuncio mostrato con successo');
        return true;
      } catch (e) {
        debugPrint('❌ Errore nella visualizzazione dell\'annuncio: $e');
        _interstitialAd = null;
        _loadInterstitialAd(); // Ricarica un altro annuncio
        return false;
      }
    } else {
      debugPrint(
        '⚠️ Nessun annuncio disponibile da mostrare, continuo senza pubblicità',
      );
      // Ricarica un annuncio per la prossima volta
      _loadInterstitialAd();
      return false;
    }
  }

  /// Precarica un annuncio da mostrare in seguito
  Future<void> preloadAd() async {
    if (_interstitialAd == null && !_isInterstitialAdLoading) {
      debugPrint('🔄 Precaricamento annuncio per uso futuro');
      await _loadInterstitialAd();
    }
  }

  /// Libera le risorse
  void dispose() {
    if (kIsWeb) return;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _loadAttempts = 0;
  }
}
