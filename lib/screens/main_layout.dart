import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/ad_service.dart';
import 'home_screen.dart';
import 'filter_screen.dart';
import 'favorite_stories_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const FilterScreen(),
    const FavoriteStoriesScreen(),
    const SettingsScreen(),
  ];

  // Gestisce il cambio di schermata
  void _onItemSelected(int index) {
    // Se l'utente sta selezionando "Crea Storia" (indice 1), mostra un annuncio
    if (index == 1) {
      _adService.showInterstitialAd();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ottieni le dimensioni dello schermo
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;

    return Scaffold(
      // SafeArea già gestita nelle singole schermate
      body: _screens[_selectedIndex]
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
      bottomNavigationBar: Padding(
        // Aggiungiamo padding in basso per gestire i dispositivi con barre di navigazione o home indicator
        padding: EdgeInsets.only(bottom: viewPadding.bottom > 0 ? 0 : 8),
        child: NavigationBar(
          height: 65, // Altezza fissa per coerenza tra dispositivi
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(FontAwesomeIcons.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
              label: 'Crea Storia',
            ),
            NavigationDestination(
              icon: const Icon(FontAwesomeIcons.solidHeart),
              label: 'Preferiti',
            ),
            NavigationDestination(
              icon: const Icon(FontAwesomeIcons.gear),
              label: 'Impostazioni',
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 1, end: 0),
      ),
    );
  }
}
