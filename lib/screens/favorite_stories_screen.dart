import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/back_button.dart';
import '../widgets/screen_with_particles.dart';
import 'story_display_screen.dart';
import 'package:lottie/lottie.dart';
import '../services/ad_service.dart';
import 'filter_screen.dart';

class FavoriteStoriesScreen extends StatefulWidget {
  const FavoriteStoriesScreen({super.key});

  @override
  State<FavoriteStoriesScreen> createState() => _FavoriteStoriesScreenState();
}

class _FavoriteStoriesScreenState extends State<FavoriteStoriesScreen> {
  List<String> _savedStories = [];
  bool _isLoading = true;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _loadSavedStories();
  }

  Future<void> _loadSavedStories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedStories = prefs.getStringList('savedStories') ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gestione errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento delle storie: $e')),
      );
    }
  }

  Future<void> _deleteStory(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> stories = [..._savedStories];
      stories.removeAt(index);
      await prefs.setStringList('savedStories', stories);
      setState(() {
        _savedStories = stories;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Storia eliminata')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }

  Future<void> _createNewStory() async {
    // Mostra un annuncio interstiziale
    await _adService.showInterstitialAd();

    if (!mounted) return;

    // Naviga alla schermata di filtro
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ScreenWithParticles(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                                'Le Tue Storie',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.2, end: 0),
                          const SizedBox(height: 8),
                          Text(
                                'Tutte le storie che hai salvato',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: -0.1, end: 0),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _savedStories.isEmpty
                              ? _buildEmptyState(context)
                              : _buildStoryList(context),
                    ),
                  ],
                ),
              ),
              const CustomBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Calcola dimensioni proporzionali allo schermo
    final animationSize = size.width * 0.7; // 70% della larghezza dello schermo
    final titleSize = size.width * 0.055; // 5.5% della larghezza per il titolo
    final textSize =
        size.width * 0.04; // 4% della larghezza per il testo secondario
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: size.width * 0.06,
      vertical: size.height * 0.015,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: animationSize,
            height:
                animationSize *
                0.7, // Proporzione verticale leggermente ridotta
            child: Lottie.asset('assets/libro.json', fit: BoxFit.contain),
          ).animate().fadeIn(duration: 800.ms),
          SizedBox(height: size.height * 0.03),
          Text(
            'Nessuna storia salvata',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
            ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: size.height * 0.01),
          Text(
            'Le storie che salvi appariranno qui',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: textSize,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          SizedBox(height: size.height * 0.04),
          ElevatedButton.icon(
            onPressed: _createNewStory,
            icon: Icon(
              FontAwesomeIcons.wandMagicSparkles,
              size: size.width * 0.045,
            ),
            label: Text(
              'Crea una nuova storia',
              style: TextStyle(fontSize: size.width * 0.042),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStoryList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      itemCount: _savedStories.length,
      itemBuilder: (context, index) {
        // Limita la lunghezza del testo da mostrare nella preview
        final previewText =
            _savedStories[index].length > 100
                ? '${_savedStories[index].substring(0, 100)}...'
                : _savedStories[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            StoryDisplayScreen(storyText: _savedStories[index]),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            FontAwesomeIcons.bookOpen,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Storia ${index + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.trash,
                            size: 16,
                            color: colorScheme.error,
                          ),
                          onPressed: () => _deleteStory(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      previewText,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Leggi',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          FontAwesomeIcons.arrowRight,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
