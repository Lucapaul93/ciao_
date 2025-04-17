import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Per salvare
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/back_button.dart';
import 'main_layout.dart';
import 'quiz_screen.dart';
import '../services/api_service.dart';
import '../models/quiz_model.dart';

class StoryDisplayScreen extends StatefulWidget {
  final String storyText; // La storia generata viene passata qui
  final String? title; // Titolo personalizzato opzionale per la storia

  const StoryDisplayScreen({super.key, required this.storyText, this.title});

  @override
  State<StoryDisplayScreen> createState() => _StoryDisplayScreenState();
}

class _StoryDisplayScreenState extends State<StoryDisplayScreen> {
  // Creiamo un'istanza dell'ApiService che verrà riutilizzata
  final ApiService _apiService = ApiService();

  double _currentFontSize = 16.0; // Dimensione iniziale del font
  bool _isSaving = false; // Stato per feedback salvataggio
  bool _alreadySaved = false; // Per evitare salvataggi multipli (opzionale)
  final int _selectedIndex =
      1; // Per la barra di navigazione, impostato sulla creazione storia
  bool _isGeneratingQuiz = false;

  // Funzione per salvare la storia
  Future<void> _saveStory() async {
    if (_alreadySaved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Storia già salvata!')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      // Recupera la lista delle storie salvate (o una lista vuota se non esiste)
      final List<String> savedStories =
          prefs.getStringList('savedStories') ?? [];

      // Aggiungi la nuova storia alla lista
      // Potresti voler aggiungere un controllo per non salvare duplicati esatti
      if (!savedStories.contains(widget.storyText)) {
        savedStories.add(widget.storyText);
        // Salva la lista aggiornata
        await prefs.setStringList('savedStories', savedStories);
        setState(() {
          _alreadySaved = true; // Marca come salvata
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storia salvata con successo!')),
        );
      } else {
        setState(() {
          _alreadySaved = true; // Era già presente, marca come salvata comunque
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Questa storia era già presente tra quelle salvate.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il salvataggio: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isGeneratingQuiz = true;
    });

    try {
      final quiz = await _apiService.generateQuiz(widget.storyText);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella generazione del quiz: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingQuiz = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom;
    final width = mediaQuery.size.width;

    return Scaffold(
      body: SafeArea(
        // Usiamo bottom: false per gestire manualmente il padding inferiore
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con titolo e pulsante salva
                _buildHeader(context),

                // Area principale con la storia
                Expanded(child: _buildStoryContent(context)),

                // Controlli dimensione testo
                _buildTextSizeControls(context),

                // Padding aggiuntivo per dispositivi con home indicator o barre di navigazione
                SizedBox(height: bottomPadding),

                // Contenitore centrato per il pulsante del quiz
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isGeneratingQuiz
                                ? () {
                                  // Annulla la generazione del quiz usando l'istanza esistente
                                  _apiService.cancelRequests();
                                  setState(() {
                                    _isGeneratingQuiz = false;
                                  });
                                }
                                : _generateQuiz,
                        icon:
                            _isGeneratingQuiz
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.quiz),
                        label: Text(
                          _isGeneratingQuiz
                              ? 'Annulla Generazione'
                              : 'Fai il Quiz!',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const CustomBackButton(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        // Aggiungiamo padding in basso solo se necessario
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 8),
        child: NavigationBar(
          height: 65, // Altezza fissa per coerenza tra dispositivi
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index != _selectedIndex) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainLayout(initialIndex: index),
                ),
              );
            }
          },
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

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(56, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'La tua storia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title ?? 'Buona lettura!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSaving ? null : _saveStory,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _alreadySaved
                          ? colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child:
                    _isSaving
                        ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        )
                        : Icon(
                          _alreadySaved
                              ? FontAwesomeIcons.solidBookmark
                              : FontAwesomeIcons.bookmark,
                          size: 20,
                          color: colorScheme.primary,
                        ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStoryContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    // Dividiamo il testo in paragrafi
    final paragraphs =
        widget.storyText
            .split('\n\n')
            .where((p) => p.trim().isNotEmpty)
            .toList();

    if (paragraphs.isEmpty) {
      paragraphs.add(widget.storyText);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prima lettera decorativa e primo paragrafo
              if (paragraphs.isNotEmpty && paragraphs[0].isNotEmpty)
                _buildFirstParagraph(paragraphs[0], theme, colorScheme),

              // Resto dei paragrafi
              ...paragraphs
                  .skip(1)
                  .map(
                    (paragraph) => Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        paragraph,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: _currentFontSize,
                          height: 1.7,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

              // Spazio finale per non tagliare il testo
              const SizedBox(height: 40),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ),
    );
  }

  Widget _buildFirstParagraph(
    String paragraph,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Se il paragrafo è troppo corto, lo mostriamo normalmente
    if (paragraph.length < 2) {
      return Text(
        paragraph,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: _currentFontSize,
          height: 1.7,
          letterSpacing: 0.3,
        ),
      );
    }

    final firstLetter = paragraph.substring(0, 1);
    final restOfText = paragraph.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prima lettera grande e decorativa
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  firstLetter.toUpperCase(),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  restOfText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: _currentFontSize,
                    height: 1.7,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextSizeControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.font, size: 16, color: colorScheme.primary),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _currentFontSize,
                min: 12,
                max: 24,
                divisions: 6,
                onChanged: (value) {
                  setState(() {
                    _currentFontSize = value;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentFontSize.toInt()}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
