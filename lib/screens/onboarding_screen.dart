import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;
  bool _isTransitioning = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Segna onboarding come completato
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);

    // Naviga alla home
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  // Gestisce la transizione tra le pagine con animazione
  void _goToNextPage() {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Dimensioni proporzionali
    final buttonFontSize = size.width * 0.045;
    final skipButtonSize = size.width * 0.04;
    final indicatorWidth = size.width * 0.06;
    final indicatorHeight = size.height * 0.01;
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: size.width * 0.08,
      vertical: size.height * 0.015,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo
          Positioned.fill(
            child: Image.asset('assets/images/sfondo4.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // Contenuto principale
          SafeArea(
            child: Column(
              children: [
                // Carosello
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPage(
                        context,
                        'assets/immagine1.png',
                        'Crea Storie Magiche',
                        'Personalizza storie uniche per i tuoi bambini con pochi semplici clic',
                        1,
                      ),
                      _buildPage(
                        context,
                        'assets/immagine2.png',
                        'Salva i Tuoi Preferiti',
                        'Conserva tutte le storie che ami in un posto facilmente accessibile',
                        2,
                      ),
                      _buildPage(
                        context,
                        'assets/immagine3.png',
                        'Scopri Storie Casuali',
                        'Lasciati sorprendere da nuove avventure generate automaticamente',
                        3,
                      ),
                    ],
                  ),
                ),

                // Indicatori e pulsanti
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.025,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicatori di pagina
                      Row(
                        children: List.generate(
                          _numPages,
                          (index) => _buildPageIndicator(
                            index == _currentPage,
                            indicatorWidth,
                            indicatorHeight,
                          ),
                        ),
                      ),

                      // Pulsante Avanti/Inizia
                      ElevatedButton(
                        onPressed: _isTransitioning ? null : _goToNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: buttonPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _currentPage < _numPages - 1 ? 'Avanti' : 'Inizia',
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pulsante salta
          Positioned(
            top: size.height * 0.05,
            right: size.width * 0.05,
            child: TextButton(
              onPressed: _isTransitioning ? null : _completeOnboarding,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Salta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: skipButtonSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Lottie animation overlay tra le transizioni
          if (_isTransitioning)
            Positioned.fill(
              child: Lottie.asset(
                'assets/magic_transition.json',
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    String imagePath,
    String title,
    String description,
    int pageNumber,
  ) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Dimensioni proporzionali allo schermo
    final imageSize = size.width * 0.75;
    final titleSize = size.width * 0.06;
    final descriptionSize = size.width * 0.042;
    final containerPadding = size.width * 0.05;
    final decorationSize = size.width * 0.12;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spazio superiore
          const Spacer(flex: 1),

          // Immagine principale con effetto 3D
          Container(
                height: imageSize,
                width: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Ombra più profonda per dare rilievo
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    // Highlight
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Transform(
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Aggiunge prospettiva
                        ..rotateX(0.05) // Leggera rotazione per effetto 3D
                        ..rotateY(-0.05),
                  alignment: FractionalOffset.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          SizedBox(height: size.height * 0.04),

          // Contenitore per titolo e descrizione con sfondo semi-trasparente
          Container(
            width: size.width * 0.85,
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Titolo
                Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: titleSize,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                SizedBox(height: size.height * 0.015),

                // Descrizione
                Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                        fontSize: descriptionSize,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 700.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),

          // Spazio inferiore
          const Spacer(flex: 2),

          // Decorazione piccola relativa alla pagina
          SizedBox(
                width: decorationSize,
                height: decorationSize,
                child: _buildPageDecoration(pageNumber, decorationSize * 0.5),
              )
              .animate()
              .fadeIn(duration: 800.ms, delay: 900.ms)
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),

          SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }

  Widget _buildPageDecoration(int pageNumber, double iconSize) {
    final icons = [
      FontAwesomeIcons.wandMagicSparkles,
      FontAwesomeIcons.solidHeart,
      FontAwesomeIcons.dice,
    ];

    final colors = [
      const Color(0xFF9C27B0),
      const Color(0xFFFF7A8A),
      const Color(0xFF64DFDF),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors[pageNumber - 1].withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: colors[pageNumber - 1].withOpacity(0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[pageNumber - 1].withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icons[pageNumber - 1],
        color: colors[pageNumber - 1],
        size: iconSize,
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive, double width, double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: height,
      width: isActive ? width : height,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                : null,
      ),
    );
  }
}
