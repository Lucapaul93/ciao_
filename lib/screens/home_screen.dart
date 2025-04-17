import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../widgets/back_button.dart';
import '../widgets/magic_particles.dart';
import '../widgets/screen_with_particles.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../utils/responsive_size.dart';
import 'filter_screen.dart';
import 'story_display_screen.dart';
import 'main_layout.dart';
import 'favorite_stories_screen.dart';
import 'onboarding_screen.dart';

// Funzione helper globale per generare una storia casuale
Future<void> generateRandomStory(BuildContext context) async {
  final currentTheme = Theme.of(context);
  final colorScheme = currentTheme.colorScheme;

  // Timer e messaggi per la schermata di caricamento
  Timer? _loadingTimer;
  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = const [
    "Sto sognando la tua storia...",
    "Mescolando un po' di magia...",
    "Consultando le stelle narranti...",
    "Cercando le parole giuste...",
    "Accendendo la fantasia...",
    "Quasi pronto per l'avventura!",
    "Shhh... l'ispirazione sta arrivando!",
    "Un pizzico di polvere di fata...",
    "Tessendo la trama del racconto...",
  ];

  // Flag per tenere traccia se la generazione è stata annullata
  bool isCancelled = false;

  // Variabili per i filtri selezionati
  String? _selectedTheme;
  String? _selectedCharacter;
  String? _selectedSetting;

  // Dialog controller per poter chiudere il dialogo anche da fuori del builder
  late BuildContext dialogContext;

  // Mostra un dialogo di caricamento
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      dialogContext = ctx;
      return StatefulBuilder(
        builder: (context, setState) {
          // Avvia il timer per cambiare i messaggi di caricamento
          _loadingTimer?.cancel();
          _loadingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
            if (!context.mounted) {
              timer.cancel();
              return;
            }
            setState(() {
              _currentMessageIndex =
                  (_currentMessageIndex + 1) % _loadingMessages.length;
            });
          });

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animazione Lottie
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Lottie.asset(
                      'assets/loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Messaggio principale
                  Text(
                    'Creazione Storia Magica',
                    style: currentTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Messaggi rotanti
                  Text(
                    _loadingMessages[_currentMessageIndex],
                    style: currentTheme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 24),

                  // Dettagli della storia
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLoadingDetail(
                          context,
                          'Tema: ${_selectedTheme?.capitalize() ?? "Casuale"}',
                          FontAwesomeIcons.wandMagicSparkles,
                        ),
                        const SizedBox(height: 8),
                        _buildLoadingDetail(
                          context,
                          'Protagonista: ${_selectedCharacter?.capitalize() ?? "Casuale"}',
                          FontAwesomeIcons.userAstronaut,
                        ),
                        const SizedBox(height: 8),
                        _buildLoadingDetail(
                          context,
                          'Ambientazione: ${_selectedSetting?.capitalize() ?? "Casuale"}',
                          FontAwesomeIcons.tree,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pulsante Annulla
                  ElevatedButton.icon(
                        onPressed: () {
                          // Imposta il flag di annullamento
                          isCancelled = true;
                          // Cancella il timer
                          _loadingTimer?.cancel();
                          // Chiudi il dialogo
                          Navigator.of(dialogContext).pop();
                        },
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Annulla',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.5, end: 0),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  try {
    // Se l'utente ha annullato, esci dalla funzione
    if (isCancelled) return;

    // Lista di opzioni possibili
    final List<String> ageRanges = ['2-5 anni', '6-8 anni', '9-12 anni'];
    final List<String> lengths = ['breve', 'media', 'lunga'];
    final List<String> themes = [
      'animali',
      'avventura',
      'magia',
      'amicizia',
      'natura',
      'fiaba classica',
    ];
    final List<String> characters = [
      'orsetto',
      'principessa',
      'supereroe',
      'bambino/a curioso/a',
      'coniglietto',
      'volpe astuta',
    ];
    final List<String> settings = [
      'bosco incantato',
      'castello maestoso',
      'spazio siderale',
      'fattoria allegra',
      'spiaggia soleggiata',
      'città vivace',
    ];
    final List<String> emotions = [
      'gioia',
      'coraggio',
      'calma',
      'curiosità',
      'gentilezza',
      'meraviglia',
    ];
    final List<String?> complexThemes = [
      null,
      'superare la paura',
      'l\'importanza dell\'amicizia',
      'accettare le differenze',
      'essere pazienti',
    ];
    final List<String?> morals = [
      null,
      'imparare a condividere',
      'essere gentili con tutti',
      'l\'onestà premia sempre',
      'l\'importanza di ascoltare',
    ];

    // Genera valori casuali
    final random = Random();
    final String ageRange = ageRanges[random.nextInt(ageRanges.length)];
    final String storyLength = lengths[random.nextInt(lengths.length)];
    final String theme = themes[random.nextInt(themes.length)];
    final String character = characters[random.nextInt(characters.length)];
    final String setting = settings[random.nextInt(settings.length)];
    final String emotion = emotions[random.nextInt(emotions.length)];
    final String? complexTheme =
        complexThemes[random.nextInt(complexThemes.length)];
    final String? moral = morals[random.nextInt(morals.length)];

    final apiService = ApiService();
    final story = await apiService.generateStory(
      ageRange: ageRange,
      storyLength: storyLength,
      theme: theme,
      mainCharacter: character,
      setting: setting,
      emotion: emotion,
      complexTheme: complexTheme,
      moral: moral,
      childName: null,
    );

    // Chiudi il dialogo di caricamento se ancora aperto e il contesto è valido
    if (context.mounted && Navigator.canPop(dialogContext)) {
      Navigator.of(dialogContext).pop();
    }

    // Naviga alla schermata di visualizzazione se il contesto è ancora valido e non è stato annullato
    if (context.mounted && !isCancelled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryDisplayScreen(storyText: story),
        ),
      );
    }
  } catch (e) {
    // Chiudi il dialogo di caricamento se ancora aperto e il contesto è valido
    if (context.mounted && !isCancelled && Navigator.canPop(dialogContext)) {
      Navigator.of(dialogContext).pop();

      // Estrai il messaggio di errore dalla Exception
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.split('Exception: ')[1];
      }

      // Mostra un dialog di errore con informazioni utili
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveSize.cardRadius),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: ResponsiveSize.sp(6.0),
                ),
                SizedBox(width: ResponsiveSize.wp(2.0)),
                Text(
                  'Errore',
                  style: TextStyle(
                    fontSize: ResponsiveSize.sp(5.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Non è stato possibile generare la storia:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: ResponsiveSize.hp(1.0)),
                Text(
                  errorMessage,
                  style: TextStyle(fontSize: ResponsiveSize.sp(3.8)),
                ),
                if (errorMessage.contains('Vercel') ||
                    errorMessage.contains('server') ||
                    errorMessage.contains('sovraccarico'))
                  Padding(
                    padding: EdgeInsets.only(top: ResponsiveSize.hp(2.0)),
                    child: Text(
                      'Il server potrebbe essere temporaneamente sovraccarico. Riprova più tardi.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: ResponsiveSize.sp(3.5),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSize.cardRadius / 2,
                    ),
                  ),
                ),
                child: Text(
                  'Chiudi',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Riprova a generare una storia
                  generateRandomStory(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: currentTheme.colorScheme.primary.withOpacity(
                    0.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSize.cardRadius / 2,
                    ),
                  ),
                ),
                child: Text(
                  'Riprova',
                  style: TextStyle(
                    color: currentTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

// Widget per visualizzare i dettagli durante il caricamento
Widget _buildLoadingDetail(BuildContext context, String text, IconData icon) {
  final colorScheme = Theme.of(context).colorScheme;
  return Row(
    children: [
      Icon(icon, size: 14, color: colorScheme.primary),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    ],
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveSize.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTablet = ResponsiveSize.isTablet;

    // Ottieni le dimensioni di sicurezza
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final screenSize = mediaQuery.size;

    // Calcola il padding dinamico in base alle dimensioni dello schermo
    final horizontalPadding = ResponsiveSize.wp(isTablet ? 4.0 : 6.0);

    return Scaffold(
      body: SafeArea(
        // Usiamo bottom: false per gestire manualmente il padding inferiore
        bottom: false,
        child: Stack(
          children: [
            // Immagine di sfondo a pagina intera
            Positioned.fill(
              child: Image.asset(
                'assets/images/sfondo4.png',
                fit: BoxFit.cover,
              ),
            ),
            // Overlay semi-trasparente per migliorare la leggibilità del contenuto
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
            // Effetto particelle magiche
            const Positioned.fill(child: MagicParticles(numberOfParticles: 60)),

            // Sostituiamo ScrollView con un layout statico usando Padding e Column
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                // Aggiungiamo padding in alto proporzionale
                viewPadding.top + ResponsiveSize.hp(isTablet ? 3.0 : 4.0),
                horizontalPadding,
                // Aggiungiamo padding in basso per evitare sovrapposizioni con la barra di navigazione
                ResponsiveSize.hp(isTablet ? 2.0 : 3.0) + viewPadding.bottom,
              ),
              child: Center(
                child: SizedBox(
                  // Utilizziamo un'altezza definita che si adatta allo schermo
                  height:
                      screenSize.height - viewPadding.top - viewPadding.bottom,
                  child: Column(
                    // Distribuiamo il contenuto equamente nello spazio disponibile
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Contenitore per il titolo e sottotitolo con sfondo semitrasparente
                      Container(
                        width: double.infinity,
                        // Su tablet riduciamo il padding per evitare che il titolo occupi troppo spazio
                        padding: ResponsiveSize.padding(
                          vertical: isTablet ? 1.5 : 2.0,
                          horizontal: isTablet ? 2.0 : 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(
                            ResponsiveSize.cardRadius,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Titolo animato
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                    'Mondo delle Storie',
                                    style: theme.textTheme.displayMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          // Riduciamo il font size per tablet
                                          fontSize: ResponsiveSize.sp(
                                            isTablet ? 7.0 : 8.0,
                                          ),
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                    textAlign: TextAlign.center,
                                  )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .slideY(begin: -0.2, end: 0),
                            ),

                            SizedBox(height: ResponsiveSize.hp(1.0)),

                            // Sottotitolo animato
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                    'Crea storie magiche per i tuoi bambini',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: ResponsiveSize.sp(
                                        isTablet ? 3.5 : 4.0,
                                      ),
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 600.ms)
                                  .slideX(begin: -0.2, end: 0),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms),

                      // Card principale con gradiente e ombra per creare storia
                      _buildMainActionCard(context),

                      // Grid di funzionalità con icone colorate - adattiamo in base al dispositivo
                      isTablet
                          ? _buildTabletFeaturesGrid(context)
                          : _buildFeaturesGrid(context),
                    ],
                  ),
                ),
              ),
            ),
            const CustomBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionCard(BuildContext context) {
    final theme = Theme.of(context);
    final adService = AdService();
    final isTablet = ResponsiveSize.isTablet;

    // Adattiamo l'altezza in base al dispositivo
    final cardHeight = ResponsiveSize.hp(isTablet ? 12.0 : 17.0);
    // Su tablet, limitiamo la larghezza massima
    final cardWidth =
        isTablet ? min(ResponsiveSize.wp(80.0), 500.0) : double.infinity;

    return Center(
      child: InkWell(
            onTap: () {
              // Mostra un annuncio interstiziale quando si clicca su "Crea una nuova storia"
              adService.showInterstitialAd().then((_) {
                // Naviga alla schermata di filtro dopo aver mostrato l'annuncio
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FilterScreen()),
                );
              });
            },
            borderRadius: BorderRadius.circular(
              ResponsiveSize.cardRadius * 1.25,
            ),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveSize.cardRadius * 1.25,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Pattern decorativo (cerchi semitrasparenti)
                  Positioned(
                    top: -ResponsiveSize.hp(2.5),
                    right: -ResponsiveSize.wp(5.0),
                    child: Container(
                      width: ResponsiveSize.wp(25.0),
                      height: ResponsiveSize.wp(25.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -ResponsiveSize.hp(1.2),
                    left: ResponsiveSize.wp(5.0),
                    child: Container(
                      width: ResponsiveSize.wp(15.0),
                      height: ResponsiveSize.wp(15.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),

                  // Contenuto
                  Padding(
                    padding: ResponsiveSize.padding(
                      horizontal: isTablet ? 4.0 : 6.0,
                      vertical: isTablet ? 2.0 : 3.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Crea una Nuova Storia',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveSize.sp(
                                    isTablet ? 3.5 : 5.0,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: ResponsiveSize.hp(isTablet ? 0.5 : 1.0),
                              ),
                              Text(
                                'Personalizza una storia unica',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: ResponsiveSize.sp(
                                    isTablet ? 2.5 : 3.5,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: ResponsiveSize.wp(1.0)),
                        Container(
                          padding: ResponsiveSize.padding(
                            all: isTablet ? 2.0 : 3.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.wandSparkles,
                            color: theme.colorScheme.primary,
                            size:
                                ResponsiveSize.iconSize *
                                (isTablet ? 0.7 : 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .animate()
          .fadeIn(delay: 400.ms)
          .slideY(begin: 0.1, end: 0)
          .shimmer(delay: 1200.ms, duration: 1800.ms),
    );
  }

  // Layout esistente per smartphone
  Widget _buildFeaturesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final adService = AdService();

    final features = [
      {
        'icon': FontAwesomeIcons.solidHeart,
        'color': const Color(0xFFFF7A8A),
        'title': 'Preferiti',
        'description': 'Le tue storie salvate',
        'delay': 400,
        'onTap': () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainLayout(initialIndex: 2),
            ),
          );
        },
      },
      {
        'icon': FontAwesomeIcons.dice,
        'color': const Color(0xFF64DFDF),
        'title': 'Casuale',
        'description': 'Sorprenditi',
        'delay': 600,
        'onTap': () {
          // Mostra un annuncio interstiziale quando si clicca su "Casuale"
          // Prima precarichiamo l'annuncio
          adService.preloadAd().then((_) {
            // Piccolo ritardo per assicurarsi che l'annuncio sia caricato
            Future.delayed(const Duration(milliseconds: 300), () {
              adService.showInterstitialAd().then((_) {
                // Usa la funzione globale invece del metodo di classe
                generateRandomStory(context);
              });
            });
          });
        },
      },
    ];

    // Dimensione quadrata per le card (1:1 ratio)
    final cardSize = ResponsiveSize.wp(
      32.0,
    ); // 32% della larghezza dello schermo

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prima card (Preferiti)
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: _buildFeatureCard(context, features[0]),
            ),

            SizedBox(width: ResponsiveSize.wp(6.0)),

            // Seconda card (Casuale)
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: _buildFeatureCard(context, features[1]),
            ),
          ],
        ),
      ],
    );
  }

  // Nuovo layout ottimizzato per tablet con le 2 card in una riga
  Widget _buildTabletFeaturesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final adService = AdService();

    final features = [
      {
        'icon': FontAwesomeIcons.solidHeart,
        'color': const Color(0xFFFF7A8A),
        'title': 'Preferiti',
        'description': 'Le tue storie salvate',
        'delay': 400,
        'onTap': () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainLayout(initialIndex: 2),
            ),
          );
        },
      },
      {
        'icon': FontAwesomeIcons.dice,
        'color': const Color(0xFF64DFDF),
        'title': 'Casuale',
        'description': 'Sorprenditi',
        'delay': 600,
        'onTap': () {
          // Mostra un annuncio interstiziale quando si clicca su "Casuale"
          // Prima precarichiamo l'annuncio
          adService.preloadAd().then((_) {
            // Piccolo ritardo per assicurarsi che l'annuncio sia caricato
            Future.delayed(const Duration(milliseconds: 300), () {
              adService.showInterstitialAd().then((_) {
                // Usa la funzione globale invece del metodo di classe
                generateRandomStory(context);
              });
            });
          });
        },
      },
    ];

    // Dimensione quadrata per le card (1:1 ratio) - su tablet le facciamo un po' più piccole
    final cardSize = min(
      ResponsiveSize.wp(25.0),
      160.0,
    ); // Max 160px di larghezza

    // Utilizziamo un layout con 2 card in riga su tablet
    return Center(
      child: Container(
        width: min(
          ResponsiveSize.wp(60),
          500.0,
        ), // Limitiamo la larghezza massima
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prima card (Preferiti)
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: _buildFeatureCard(context, features[0]),
            ),

            SizedBox(width: ResponsiveSize.wp(4.0)),

            // Seconda card (Casuale)
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: _buildFeatureCard(context, features[1]),
            ),
          ],
        ),
      ),
    );
  }

  // Metodo per costruire una singola card di funzionalità
  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveSize.isTablet;
    final iconSize = ResponsiveSize.wp(
      isTablet ? 8.0 : 10.0,
    ); // Riduciamo leggermente su tablet

    return Card(
          elevation:
              4, // Aggiungo un po' di elevazione per migliorare l'aspetto
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveSize.cardRadius),
          ),
          child: InkWell(
            onTap: feature['onTap'] as Function(),
            borderRadius: BorderRadius.circular(ResponsiveSize.cardRadius),
            child: Padding(
              padding: ResponsiveSize.padding(all: isTablet ? 1.2 : 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icona con formato compatto
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        feature['icon'] as IconData,
                        color: feature['color'] as Color,
                        size: iconSize * 0.6,
                      ),
                    ),
                  ),

                  // Titolo
                  Flexible(
                    child: Text(
                      feature['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveSize.sp(isTablet ? 3.2 : 3.8),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Descrizione
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        feature['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: ResponsiveSize.sp(isTablet ? 2.3 : 2.8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (feature['delay'] as int).ms)
        .slideY(begin: 0.1, end: 0);
  }
}
