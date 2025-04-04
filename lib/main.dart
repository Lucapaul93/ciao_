import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/main_layout.dart';
import 'providers/theme_provider.dart';
import 'utils/performance_utils.dart';
import 'utils/responsive_size.dart';
import 'services/ad_service.dart';

// Importa le future schermate (che creeremo tra poco)
import 'screens/home_screen.dart';
import 'screens/saved_stories_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
// Importa eventuali provider (se usi provider)
// import 'providers/story_provider.dart'; // Esempio

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzo le impostazioni di performance
  await PerformanceConfig.init();

  // Inizializzo il servizio pubblicitario
  await AdService().initialize();

  // Impostiamo l'orientamento preferito (verticale)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Impostiamo la modalità edge-to-edge per sfruttare tutto lo spazio disponibile
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Impostiamo i colori della barra di stato
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Storia Magica',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              // Inizializziamo ResponsiveSize per tutto il sistema
              ResponsiveSize.init(context);

              // Applica il fattore di scala del testo utilizzando solo textScaler
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Usiamo solo textScaler e non textScaleFactor (che è deprecato)
                  textScaler: TextScaler.linear(themeProvider.textScaleFactor),
                ),
                child: child!,
              );
            },
            // Disabilita il debug banner
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

// Schermata di splash che controlla se mostrare l'onboarding o la home
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingComplete =
        prefs.getBool('onboardingComplete') ?? false;

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  onboardingComplete
                      ? const MainLayout()
                      : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o animazione di avvio
            Image.asset('assets/images/logo.png', width: 150, height: 150),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// Widget che gestisce la Bottom Navigation Bar e le schermate principali
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Indice della schermata attiva (0 = Home)

  // Lista delle schermate principali
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SavedStoriesScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar viene definita dentro ogni singola schermata se necessario
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Icona Home
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark), // Icona Storie Salvate
            label: 'Storie Salvate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Icona Impostazioni
            label: 'Impostazioni',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[800], // Colore icona selezionata
        onTap: _onItemTapped,
      ),
    );
  }
}
