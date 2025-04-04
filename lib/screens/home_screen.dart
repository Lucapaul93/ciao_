import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/back_button.dart';
import '../widgets/magic_particles.dart';
import '../widgets/screen_with_particles.dart';
import '../services/ad_service.dart';
import '../utils/responsive_size.dart';
import 'filter_screen.dart'; // Importa la schermata dei filtri (da creare)
import 'dart:math';
import '../services/api_service.dart'; // Per la generazione della storia
import 'story_display_screen.dart';
import 'main_layout.dart'; // Importa il layout principale
import 'favorite_stories_screen.dart';
import 'package:lottie/lottie.dart';

// Funzione helper globale per generare una storia casuale
Future<void> generateRandomStory(BuildContext context) async {
  final currentTheme = Theme.of(context);

  // Dimensioni proporzionali allo schermo
  final dialogWidth = ResponsiveSize.wp(85.0);
  final dialogHeight = ResponsiveSize.hp(45.0);
  final animationSize = ResponsiveSize.wp(50.0);
  final titleSize = ResponsiveSize.sp(5.0);
  final textSize = ResponsiveSize.sp(4.0);
  final buttonTextSize = ResponsiveSize.sp(4.2);

  // Flag per tenere traccia se la generazione è stata annullata
  bool isCancelled = false;

  // Dialog controller per poter chiudere il dialogo anche da fuori del builder
  late BuildContext dialogContext;

  // Mostra un dialogo di caricamento
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      dialogContext = ctx;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveSize.cardRadius * 1.25),
        ),
        contentPadding: ResponsiveSize.padding(all: 5.0),
        content: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animazione posizionata nella parte superiore
              Positioned(
                top: dialogHeight * 0.05, // 5% dell'altezza dall'alto
                child: SizedBox(
                  width: animationSize,
                  height: animationSize,
                  child: Lottie.asset(
                    'assets/caricamento.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Testo posizionato nella parte centrale inferiore
              Positioned(
                bottom: dialogHeight * 0.2, // 20% dell'altezza dal basso
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Creazione storia in corso...',
                      style: currentTheme.textTheme.titleMedium?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveSize.hp(1.5)),
                    Text(
                      'La magia richiede un po\' di tempo!',
                      style: currentTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: textSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Pulsante annulla posizionato in basso
              Positioned(
                bottom: dialogHeight * 0.05, // 5% dell'altezza dal basso
                child: TextButton(
                  onPressed: () {
                    isCancelled = true;
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: ResponsiveSize.padding(
                      horizontal: 6.0,
                      vertical: 1.2,
                    ),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveSize.cardRadius,
                      ),
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Annulla',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: buttonTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: currentTheme.colorScheme.surface,
        elevation: 8,
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ottieni le dimensioni di sicurezza
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;

    // Calcola il padding dinamico in base alle dimensioni dello schermo
    final horizontalPadding = ResponsiveSize.wp(
      ResponsiveSize.isTablet ? 5.0 : 6.0,
    );

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
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                viewPadding.top > 0
                    ? ResponsiveSize.hp(3.5)
                    : ResponsiveSize.hp(6.5),
                horizontalPadding,
                ResponsiveSize.hp(3.0) + viewPadding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Contenitore per il titolo e sottotitolo con sfondo semitrasparente
                  Container(
                    width: double.infinity,
                    padding: ResponsiveSize.padding(
                      vertical: 2.0,
                      horizontal: ResponsiveSize.isTablet ? 2.5 : 4.0,
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
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveSize.sp(8.0),
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
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
                                  fontSize: ResponsiveSize.sp(4.0),
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

                  SizedBox(height: ResponsiveSize.hp(5.0)),

                  // Card principale con gradiente e ombra per creare storia
                  _buildMainActionCard(context),

                  SizedBox(height: ResponsiveSize.hp(5.0)),

                  // Grid di funzionalità con icone colorate
                  Expanded(child: _buildFeaturesGrid(context)),
                ],
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

    return InkWell(
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
          borderRadius: BorderRadius.circular(ResponsiveSize.cardRadius * 1.25),
          child: Container(
            width: double.infinity,
            height: ResponsiveSize.hp(17.0),
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
                    horizontal: 6.0,
                    vertical: 3.0,
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
                                fontSize: ResponsiveSize.sp(5.0),
                              ),
                            ),
                            SizedBox(height: ResponsiveSize.hp(1.0)),
                            Text(
                              'Personalizza una storia unica',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: ResponsiveSize.sp(3.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: ResponsiveSize.padding(all: 3.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesomeIcons.wandSparkles,
                          color: theme.colorScheme.primary,
                          size: ResponsiveSize.iconSize * 0.9,
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
        .shimmer(delay: 1200.ms, duration: 1800.ms);
  }

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
          adService.showInterstitialAd().then((_) {
            // Usa la funzione globale invece del metodo di classe
            generateRandomStory(context);
          });
        },
      },
    ];

    // Dimensione quadrata per le card (1:1 ratio)
    final cardSize = ResponsiveSize.wp(
      32.0,
    ); // 32% della larghezza dello schermo

    return Row(
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
    );
  }

  // Metodo per costruire una singola card di funzionalità
  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    final theme = Theme.of(context);
    final iconSize = ResponsiveSize.wp(
      10.0,
    ); // 10% della larghezza dello schermo

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
              padding: ResponsiveSize.padding(all: 2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        size:
                            iconSize *
                            0.6, // 60% della dimensione del contenitore
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveSize.hp(1.0)),

                  // Titolo
                  Text(
                    feature['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveSize.sp(4.0),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),

                  SizedBox(height: ResponsiveSize.hp(0.5)),

                  // Descrizione
                  Text(
                    feature['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: ResponsiveSize.sp(3.0),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
