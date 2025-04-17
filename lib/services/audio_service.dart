import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';

class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    // Registra l'observer per il ciclo di vita dell'app
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  StreamSubscription? _volumeButtonSubscription;

  /// Inizializza il servizio audio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configura la sessione audio
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
        ),
      );

      // Ripristina la musica in base allo stato dell'audio
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          // Interruzione (ad es. chiamata in arrivo)
          _backgroundMusicPlayer.pause();
        } else {
          // Fine dell'interruzione
          if (_isMusicEnabled && event.type == AudioInterruptionType.pause) {
            _backgroundMusicPlayer.play();
          }
        }
      });

      session.becomingNoisyEventStream.listen((_) {
        // Quando vengono rimossi gli auricolari, metti in pausa
        _backgroundMusicPlayer.pause();
      });

      // Prepara il player con la canzone di sottofondo
      await _backgroundMusicPlayer.setAsset('assets/audio/canzone.MP3');
      await _backgroundMusicPlayer.setLoopMode(
        LoopMode.all,
      ); // Riproduzione continua
      await _backgroundMusicPlayer.setVolume(0.5); // Volume al 50%

      // Configura il player per ripartire automaticamente quando completato
      _backgroundMusicPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _backgroundMusicPlayer.seek(Duration.zero);
          _backgroundMusicPlayer.play();
        }
      });

      _isInitialized = true;
      debugPrint('✅ Servizio audio inizializzato con successo');
    } catch (e) {
      debugPrint('❌ Errore nell\'inizializzazione del servizio audio: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App in background o schermo spento
        pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        // App torna in foreground
        if (_isMusicEnabled) {
          playBackgroundMusic();
        }
        break;
      default:
        break;
    }
  }

  /// Avvia la riproduzione della musica di sottofondo
  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isMusicEnabled) {
      try {
        await _backgroundMusicPlayer.play();
        debugPrint('🎵 Riproduzione musica di sottofondo avviata');
      } catch (e) {
        debugPrint('❌ Errore nella riproduzione della musica: $e');
      }
    }
  }

  /// Mette in pausa la musica di sottofondo
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.pause();
      debugPrint('⏸️ Musica di sottofondo in pausa');
    } catch (e) {
      debugPrint('❌ Errore nella pausa della musica: $e');
    }
  }

  /// Imposta lo stato di attivazione della musica
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;

    if (_isInitialized) {
      if (enabled) {
        _backgroundMusicPlayer.play();
        debugPrint('🎵 Musica riattivata');
      } else {
        _backgroundMusicPlayer.pause();
        debugPrint('🔇 Musica disattivata');
      }
    }
  }

  /// Rilascia le risorse quando l'app viene chiusa
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundMusicPlayer.dispose();
    _volumeButtonSubscription?.cancel();
    debugPrint('🧹 Risorse audio rilasciate');
  }
}
