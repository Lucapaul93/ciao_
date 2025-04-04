import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Per salvare
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/back_button.dart';
import 'main_layout.dart';

class StoryDisplayScreen extends StatefulWidget {
  final String storyText; // La storia generata viene passata qui

  const StoryDisplayScreen({super.key, required this.storyText});

  @override
  State<StoryDisplayScreen> createState() => _StoryDisplayScreenState();
}

class _StoryDisplayScreenState extends State<StoryDisplayScreen> {
  double _currentFontSize = 16.0; // Dimensione iniziale del font
  bool _isSaving = false; // Stato per feedback salvataggio
  bool _alreadySaved = false; // Per evitare salvataggi multipli (opzionale)
  final int _selectedIndex =
      1; // Per la barra di navigazione, impostato sulla creazione storia

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ottieni le dimensioni di sicurezza
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final bottomPadding = mediaQuery.viewPadding.bottom;

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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _buildStoryCard(context),
                  ),
                ),

                // Controlli dimensione testo
                _buildTextSizeControls(context),

                // Padding aggiuntivo per dispositivi con home indicator o barre di navigazione
                SizedBox(height: bottomPadding),
              ],
            ),
            const CustomBackButton(onPressed: null),
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
      padding: const EdgeInsets.fromLTRB(56, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STORIA',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.clock,
                      size: 10,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'La Tua Storia',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSaving ? null : _saveStory,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          _alreadySaved
                              ? colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child:
                        _isSaving
                            ? SizedBox(
                              width: 24,
                              height: 24,
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
                              size: 22,
                              color: colorScheme.primary,
                            ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStoryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prima lettera in grande
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 8, bottom: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.storyText.substring(0, 1).toUpperCase(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.storyText.substring(1).split('.').first}.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: _currentFontSize,
                        height: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Resto del testo
              Text(
                widget.storyText.split('.').skip(1).join('.').trim(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: _currentFontSize,
                  height: 1.6,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1));
  }

  Widget _buildTextSizeControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dimensione testo:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Flexible(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.primary.withOpacity(0.2),
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withOpacity(0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: _currentFontSize,
                min: 10,
                max: 30,
                onChanged: (value) {
                  setState(() {
                    _currentFontSize = value;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _currentFontSize.toStringAsFixed(0),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
