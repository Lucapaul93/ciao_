import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/back_button.dart';
import '../widgets/screen_with_particles.dart';
import 'story_display_screen.dart';
import 'story_adventure_screen.dart';
import 'package:lottie/lottie.dart';
import '../services/ad_service.dart';
import 'filter_screen.dart';

class FavoriteStoriesScreen extends StatefulWidget {
  const FavoriteStoriesScreen({super.key});

  @override
  State<FavoriteStoriesScreen> createState() => _FavoriteStoriesScreenState();
}

class _FavoriteStoriesScreenState extends State<FavoriteStoriesScreen>
    with SingleTickerProviderStateMixin {
  List<String> _savedStories = [];
  List<Map<String, dynamic>> _savedInteractiveStories = [];
  bool _isLoading = true;
  final AdService _adService = AdService();

  // Tab controller per gestire le diverse tipologie di storie
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedStories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedStories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();

      // Carica storie classiche
      final classicStories = prefs.getStringList('savedStories') ?? [];

      // Carica storie interattive
      final interactiveStoriesRaw =
          prefs.getStringList('saved_interactive_stories') ?? [];
      final interactiveStories =
          interactiveStoriesRaw.map((storyJson) {
            try {
              return jsonDecode(storyJson) as Map<String, dynamic>;
            } catch (e) {
              print('Errore nel parsing della storia interattiva: $e');
              return <String, dynamic>{
                'error': 'Formato non valido',
                'story':
                    'Si è verificato un errore nel caricamento di questa storia.',
              };
            }
          }).toList();

      setState(() {
        _savedStories = classicStories;
        _savedInteractiveStories = interactiveStories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Gestione errore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento delle storie: $e')),
        );
      }
    }
  }

  Future<void> _deleteClassicStory(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> stories = [..._savedStories];
      stories.removeAt(index);
      await prefs.setStringList('savedStories', stories);
      setState(() {
        _savedStories = stories;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Storia eliminata')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _deleteInteractiveStory(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Recupera tutte le storie interattive
      List<String> storiesRaw =
          prefs.getStringList('saved_interactive_stories') ?? [];
      storiesRaw.removeAt(index);

      // Salva la lista aggiornata
      await prefs.setStringList('saved_interactive_stories', storiesRaw);

      // Aggiorna lo stato
      setState(() {
        _savedInteractiveStories.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storia interattiva eliminata')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    }
  }

  Future<void> _createNewStory() async {
    // Prima precarichiamo l'annuncio
    await _adService.preloadAd();

    // Piccolo ritardo per assicurarsi che l'annuncio sia caricato
    await Future.delayed(const Duration(milliseconds: 300));

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

    final bool hasAnyStories =
        _savedStories.isNotEmpty || _savedInteractiveStories.isNotEmpty;

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

                    // Tab bar per le diverse tipologie di storie (visibile solo se ci sono storie)
                    if (hasAnyStories && !_isLoading)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicatorColor: colorScheme.primary,
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurface
                              .withOpacity(0.7),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: colorScheme.primaryContainer.withOpacity(
                              0.5,
                            ),
                          ),
                          tabs: const [
                            Tab(text: 'Storie Classiche'),
                            Tab(text: 'Storie Interattive'),
                          ],
                        ),
                      ),

                    Expanded(
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : !hasAnyStories
                              ? _buildEmptyState(context)
                              : TabBarView(
                                controller: _tabController,
                                children: [
                                  // Tab 1: Storie classiche
                                  _savedStories.isEmpty
                                      ? _buildEmptyTabContent(
                                        'Nessuna storia classica salvata',
                                      )
                                      : _buildClassicStoryList(context),

                                  // Tab 2: Storie interattive
                                  _savedInteractiveStories.isEmpty
                                      ? _buildEmptyTabContent(
                                        'Nessuna storia interattiva salvata',
                                      )
                                      : _buildInteractiveStoryList(context),
                                ],
                              ),
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

  Widget _buildEmptyTabContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.bookBookmark,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewStory,
            icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
            label: const Text('Crea una nuova storia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
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

  Widget _buildClassicStoryList(BuildContext context) {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
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
                          onPressed: () => _deleteClassicStory(index),
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

  Widget _buildInteractiveStoryList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      itemCount: _savedInteractiveStories.length,
      itemBuilder: (context, index) {
        final storyData = _savedInteractiveStories[index];
        final title =
            storyData['title'] as String? ?? 'Storia interattiva ${index + 1}';

        // Limita la lunghezza del testo da mostrare nella preview
        final storyText =
            storyData['story'] as String? ??
            'Errore nel caricamento della storia';
        final previewText =
            storyText.length > 100
                ? '${storyText.substring(0, 100).replaceAll('\n\n', ' ')}...'
                : storyText;

        final filters = storyData['filters'] as Map<String, dynamic>? ?? {};
        final date =
            storyData['date'] != null
                ? DateTime.parse(storyData['date'] as String)
                : null;

        final formattedDate =
            date != null ? '${date.day}/${date.month}/${date.year}' : '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                // Poiché non possiamo riaprire la storia interattiva esattamente com'era,
                // mostriamo il testo completo in modalità lettura
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StoryDisplayScreen(
                          storyText: storyText,
                          title: title,
                        ),
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
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            FontAwesomeIcons.bookBookmark,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (formattedDate.isNotEmpty)
                                Text(
                                  formattedDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.trash,
                            size: 16,
                            color: colorScheme.error,
                          ),
                          onPressed: () => _deleteInteractiveStory(index),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Mostra i tag dei filtri utilizzati
                    if (filters.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (filters['theme'] != null)
                            _buildFilterChip(
                              filters['theme'],
                              colorScheme.primary,
                            ),
                          if (filters['mainCharacter'] != null)
                            _buildFilterChip(
                              filters['mainCharacter'],
                              colorScheme.tertiary,
                            ),
                          if (filters['setting'] != null)
                            _buildFilterChip(
                              filters['setting'],
                              colorScheme.secondary,
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
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          FontAwesomeIcons.arrowRight,
                          size: 12,
                          color: colorScheme.secondary,
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

  Widget _buildFilterChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
