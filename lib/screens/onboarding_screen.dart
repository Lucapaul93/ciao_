import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_size.dart';
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
  final int _numPages = 5;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    // Inizializza le dimensioni responsive
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ResponsiveSize.init(context);
      }
    });
  }

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
    // Assicuriamoci che ResponsiveSize sia inizializzato
    ResponsiveSize.init(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final isTablet = ResponsiveSize.isTablet;

    // Calcola dimensioni responsive
    final indicatorWidth = ResponsiveSize.wp(isTablet ? 4.0 : 6.0);
    final indicatorHeight = ResponsiveSize.hp(isTablet ? 0.7 : 1.0);

    // Padding più compatto per tablet
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: ResponsiveSize.wp(isTablet ? 4.0 : 8.0),
      vertical: ResponsiveSize.hp(isTablet ? 1.0 : 1.5),
    );

    // Font size più appropriate
    final buttonFontSize = ResponsiveSize.sp(isTablet ? 3.5 : 4.5);
    final skipButtonSize = ResponsiveSize.sp(isTablet ? 3.0 : 4.0);

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Carosello
                Expanded(
                  child: Center(
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
                        _buildPage(
                          context,
                          'assets/immagine4.png',
                          'Storie a Bivi',
                          'Scegli tu il percorso della storia! Ad ogni bivio, decidi come proseguire l\'avventura',
                          4,
                        ),
                        _buildPage(
                          context,
                          'assets/immagine5.png',
                          'Personalizza con il Nome',
                          'Inserisci il nome del tuo bambino e vedilo diventare il protagonista della storia',
                          5,
                        ),
                      ],
                    ),
                  ),
                ),

                // Indicatori e pulsanti
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveSize.wp(6.0),
                    vertical: ResponsiveSize.hp(2.0),
                  ),
                  width: double.infinity,
                  child: SafeArea(
                    top: false,
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
                ),
              ],
            ),
          ),

          // Pulsante salta
          Positioned(
            top: viewPadding.top + ResponsiveSize.hp(2.0),
            right: ResponsiveSize.wp(5.0),
            child: TextButton(
              onPressed: _isTransitioning ? null : _completeOnboarding,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSize.wp(4.0),
                  vertical: ResponsiveSize.hp(1.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
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
            ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0),
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
    ResponsiveSize.init(context);
    final theme = Theme.of(context);
    final isTablet = ResponsiveSize.isTablet;

    // Dimensioni proporzionali allo schermo, ottimizzate sia per tablet che per smartphone
    final imageSize =
        isTablet
            ? ResponsiveSize.wp(60.0) // Più piccola in percentuale su tablet
            : ResponsiveSize.wp(75.0);

    final titleSize = ResponsiveSize.sp(isTablet ? 5.0 : 6.0);
    final descriptionSize = ResponsiveSize.sp(isTablet ? 3.5 : 4.2);
    final containerPadding = ResponsiveSize.wp(isTablet ? 3.0 : 5.0);
    final decorationSize = ResponsiveSize.wp(isTablet ? 9.0 : 12.0);

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSize.wp(isTablet ? 3.0 : 6.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Immagine principale con effetto 3D
              Container(
                    height: imageSize,
                    width: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
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
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(0.05)
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
                  .scale(begin: const Offset(0.8, 0.8)),

              SizedBox(height: ResponsiveSize.hp(4.0)),

              // Contenitore per titolo e descrizione
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(containerPadding),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: titleSize,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    SizedBox(height: ResponsiveSize.hp(2.0)),

                    Text(
                          description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: descriptionSize,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 700.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveSize.hp(4.0)),

              // Decorazione
              SizedBox(
                    width: decorationSize,
                    height: decorationSize,
                    child: _buildPageDecoration(
                      pageNumber,
                      decorationSize * 0.5,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 900.ms)
                  .scale(begin: const Offset(0, 0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageDecoration(int pageNumber, double iconSize) {
    final icons = [
      FontAwesomeIcons.wandMagicSparkles,
      FontAwesomeIcons.solidHeart,
      FontAwesomeIcons.dice,
      FontAwesomeIcons.road,
      FontAwesomeIcons.child,
    ];

    final colors = [
      const Color(0xFF9C27B0),
      const Color(0xFFFF7A8A),
      const Color(0xFF64DFDF),
      const Color(0xFFFFA726),
      const Color(0xFF4CAF50),
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
