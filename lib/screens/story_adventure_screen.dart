import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Per jsonEncode
import '../services/api_service.dart';
import '../widgets/back_button.dart';

class StoryAdventureScreen extends StatefulWidget {
  final Map<String, dynamic> initialStoryData;
  final Map<String, dynamic> storyFilters;

  const StoryAdventureScreen({
    Key? key,
    required this.initialStoryData,
    required this.storyFilters,
  }) : super(key: key);

  @override
  State<StoryAdventureScreen> createState() => _StoryAdventureScreenState();
}

class _StoryAdventureScreenState extends State<StoryAdventureScreen> {
  // Creiamo un'istanza dell'ApiService che verrà riutilizzata
  final ApiService _apiService = ApiService();

  // Lista dei segmenti della storia visualizzati finora
  final List<String> _storySegments = [];

  // Scelte correnti disponibili
  List<String> _currentChoices = [];

  // Flag per indicare se la storia è terminata
  bool _isStoryFinished = false;

  // Flag per indicare se è in corso un caricamento
  bool _isLoading = false;

  // Flag per indicare se la storia è stata salvata nei preferiti
  bool _isSaved = false;

  // Contatore dei segmenti della storia
  int _segmentCount = 1;

  // Scroll controller per scorrere automaticamente verso il basso
  final ScrollController _scrollController = ScrollController();

  // Font size
  double _fontSize = 18.0;
  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 28.0; // Aumentato da 18 a 28

  // Controller per l'animazione dello sfondo
  late final AnimationController _backgroundAnimController;

  @override
  void initState() {
    super.initState();
    // Inizializza con i dati iniziali della storia
    _storySegments.add(widget.initialStoryData['segment']);
    _currentChoices = List<String>.from(widget.initialStoryData['choices']);
    _isStoryFinished = widget.initialStoryData['is_final'] ?? false;
    _segmentCount = widget.initialStoryData['segmentCount'] ?? 1;

    // Log per debug
    print('Storia iniziata con segmento $_segmentCount di 3');

    // Controlla se la storia è già nei preferiti
    _checkIfSaved();
  }

  // Verifica se la storia è già stata salvata
  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStories = prefs.getStringList('saved_interactive_stories') ?? [];

    // Crea un identificatore unico per questa storia basato sui filtri
    final storyIdentifier =
        '${widget.storyFilters['theme']}_${widget.storyFilters['mainCharacter']}_${DateTime.now().day}';

    setState(() {
      _isSaved = savedStories.any((story) => story.contains(storyIdentifier));
    });
  }

  // Salva la storia nei preferiti
  Future<void> _saveStory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStories =
          prefs.getStringList('saved_interactive_stories') ?? [];

      // Ottieni la storia completa
      final completeStory = _storySegments.join('\n\n');

      // Crea un identificatore unico per questa storia
      final storyIdentifier =
          '${widget.storyFilters['theme']}_${widget.storyFilters['mainCharacter']}_${DateTime.now().day}';

      // Crea una entry per la storia salvata con titolo e metadata
      final storyEntry = {
        'id': storyIdentifier,
        'title': 'Storia interattiva: ${widget.storyFilters['theme']}',
        'story': completeStory,
        'date': DateTime.now().toIso8601String(),
        'interactive': true,
        'filters': widget.storyFilters,
      };

      // Aggiungi la storia all'elenco delle storie salvate
      savedStories.add(jsonEncode(storyEntry));
      await prefs.setStringList('saved_interactive_stories', savedStories);

      setState(() {
        _isSaved = true;
      });

      // Mostra conferma
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Storia salvata nei preferiti!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore durante il salvataggio: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Funzione per continuare la storia quando l'utente sceglie un'opzione
  Future<void> _continueStory(String chosenOption) async {
    // Evita di procedere se un'operazione è già in corso
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Costruisci la storia finora
      final storyHistory = _storySegments.join('\n\n');

      // Log per debug
      print(
        'Richiesta continuazione storia - segmento corrente: $_segmentCount',
      );

      // Chiama l'API per continuare la storia usando l'istanza esistente
      final continueData = await _apiService.continueStory(
        storyHistory: storyHistory,
        chosenOption: chosenOption,
        segmentCount: _segmentCount,
      );

      // Aggiorna lo stato con i nuovi dati
      setState(() {
        // Aggiungi il testo della scelta fatta
        _storySegments.add('\n\n**$chosenOption**\n\n');
        // Aggiungi il nuovo segmento di storia
        _storySegments.add(continueData['segment']);
        // Aggiorna le nuove scelte
        _currentChoices = List<String>.from(continueData['choices']);
        // Aggiorna lo stato di fine storia
        _isStoryFinished = continueData['is_final'] ?? false;
        // Aggiorna il conteggio dei segmenti
        _segmentCount = continueData['segmentCount'] ?? (_segmentCount + 1);
        // Fine caricamento
        _isLoading = false;

        // Log per debug
        print(
          'Storia aggiornata - nuovo segmento: $_segmentCount, finale: $_isStoryFinished',
        );
      });

      // Scorri verso il basso per mostrare il nuovo contenuto
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Mostra un messaggio di errore con lo stesso stile del pulsante Annulla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Generazione storia annullata',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

      // Log dell'errore originale per debugging
      print('Errore durante la generazione della storia: $e');
    }
  }

  // Funzione per cambiare la dimensione del testo
  void _changeFontSize(double size) {
    setState(() {
      _fontSize = size.clamp(_minFontSize, _maxFontSize);
    });
  }

  // Widget per mostrare una scelta fatta
  Widget _buildChoiceSegment(String segment, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          segment.replaceAll('**', ''),
          style: TextStyle(
            fontSize: _fontSize - 1,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // Widget per mostrare un segmento di storia
  Widget _buildStorySegment(String segment, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        segment,
        style: TextStyle(
          fontSize: _fontSize,
          height: 1.5,
          color: colorScheme.onSurface,
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewPadding.bottom;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary.withOpacity(0.1), colorScheme.surface],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Elementi decorativi di sfondo
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: const Duration(seconds: 3),
                      curve: Curves.easeInOut,
                    ),
              ),

              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withOpacity(0.1),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: const Duration(milliseconds: 2500),
                      curve: Curves.easeInOut,
                    ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con titolo e controlli
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Storia Interattiva',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        // Controlli dimensione testo
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease, size: 20),
                              onPressed: () => _changeFontSize(_fontSize - 1),
                              tooltip: 'Testo più piccolo',
                              color: colorScheme.primary,
                            ),
                            Text(
                              _fontSize.round().toString(),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_increase, size: 20),
                              onPressed: () => _changeFontSize(_fontSize + 1),
                              tooltip: 'Testo più grande',
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Area principale con la storia
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Column(
                          children: [
                            // Area di scorrimento della storia
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Titolo della storia basato sui filtri
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        child: Text(
                                          'Un\'avventura ${widget.storyFilters['theme']}',
                                          style: TextStyle(
                                            fontSize: _fontSize + 4,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),

                                    // Contenuto della storia con rendering migliorato
                                    ..._storySegments.asMap().entries.map((
                                      entry,
                                    ) {
                                      final int i = entry.key;
                                      final String segment = entry.value;

                                      if (i % 2 == 1 && i > 0) {
                                        // Questo è un segmento che mostra la scelta fatta
                                        return _buildChoiceSegment(segment, i);
                                      } else {
                                        // Questo è un segmento di storia normale
                                        return _buildStorySegment(segment, i);
                                      }
                                    }).toList(),

                                    // Spinner di caricamento se si sta continuando la storia
                                    if (_isLoading)
                                      Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Continuo la storia...',
                                                style: TextStyle(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              // Pulsante Annulla
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  // Annulla la richiesta API usando l'istanza esistente
                                                  _apiService.cancelRequests();
                                                  // Disattiva l'indicatore di caricamento
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.cancel_outlined,
                                                ),
                                                label: const Text('Annulla'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.red.shade400,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    // Messaggio finale se la storia è completa e pulsante salva
                                    if (_isStoryFinished && !_isLoading)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 32,
                                          bottom: 16,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  FontAwesomeIcons.bookOpen,
                                                  color: colorScheme.primary,
                                                  size: 32,
                                                ),
                                              ).animate().scale(
                                                duration: 600.ms,
                                                curve: Curves.elasticOut,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Fine della storia',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Complimenti! Hai raggiunto la fine di questa avventura.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: _fontSize - 2,
                                                ),
                                              ),
                                              const SizedBox(height: 24),

                                              // Pulsante per salvare la storia
                                              ElevatedButton.icon(
                                                onPressed: _saveStory,
                                                icon: Icon(
                                                  _isSaved
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                ),
                                                label: Text(
                                                  _isSaved
                                                      ? 'Salvata nei preferiti'
                                                      : 'Salva nei preferiti',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      _isSaved
                                                          ? colorScheme
                                                              .primaryContainer
                                                          : colorScheme.primary,
                                                  foregroundColor:
                                                      _isSaved
                                                          ? colorScheme
                                                              .onPrimaryContainer
                                                          : colorScheme
                                                              .onPrimary,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).animate().fadeIn(duration: 800.ms),

                                    // Area delle scelte
                                    if (!_isStoryFinished &&
                                        _currentChoices.isNotEmpty &&
                                        !_isLoading)
                                      Container(
                                        margin: const EdgeInsets.only(top: 16),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surface,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, -5),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          16 + bottomPadding,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                                bottom: 12,
                                              ),
                                              child: Text(
                                                'Cosa vuoi fare?',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            ...List.generate(_currentChoices.length, (
                                              index,
                                            ) {
                                              return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 10,
                                                        ),
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          _isLoading
                                                              ? null
                                                              : () => _continueStory(
                                                                _currentChoices[index],
                                                              ),
                                                      style: ElevatedButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 16,
                                                            ),
                                                        backgroundColor:
                                                            colorScheme.primary,
                                                        foregroundColor:
                                                            colorScheme
                                                                .onPrimary,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        minimumSize: const Size(
                                                          double.infinity,
                                                          0,
                                                        ),
                                                        elevation: 2,
                                                      ),
                                                      child: Text(
                                                        _currentChoices[index],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                  .animate()
                                                  .fadeIn(
                                                    delay: (200 * index).ms,
                                                  )
                                                  .slideY(begin: 0.2, end: 0);
                                            }),
                                          ],
                                        ),
                                      ).animate().fadeIn(duration: 300.ms),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
      ),
    );
  }
}
