import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart'; // Importa il servizio API
import '../widgets/back_button.dart';
import '../widgets/screen_with_particles.dart'; // Importa il nuovo widget
import '../services/ad_service.dart'; // Importa il servizio per gli annunci
import 'story_display_screen.dart'; // Importa la schermata per visualizzare la storia
import 'package:lottie/lottie.dart';
import 'story_adventure_screen.dart'; // Importa la schermata per la storia interattiva
import 'dart:async';

// Classe per le opzioni del tema complesso
class ComplexThemeOption {
  final String? value;
  final String label;

  ComplexThemeOption(this.value, this.label);
}

// Classe per le opzioni della morale
class MoralOption {
  final String? value;
  final String label;

  MoralOption(this.value, this.label);
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Stato per tenere traccia dei valori selezionati
  String? _selectedAgeRange = '2-5 anni'; // Valore iniziale di default
  String? _selectedLength = 'breve';
  String? _selectedTheme = 'animali';
  String? _selectedCharacter = 'orsetto';
  String? _selectedSetting =
      'bosco incantato'; // Corretto il valore per corrispondere alla lista
  String? _selectedEmotion = 'gioia';
  String? _selectedComplexTheme; // Nessuno di default
  String? _selectedMoral; // Nessuno di default

  // Controller per il campo del nome del bambino
  final TextEditingController _childNameController = TextEditingController();

  bool _isLoading = false; // Per mostrare un indicatore di caricamento
  bool _isAdvancedOptionsExpanded =
      false; // Per controllare l'espansione delle opzioni avanzate

  // Flag per la modalità storia interattiva
  bool _isInteractiveMode = false;

  // Timer e messaggi per la schermata di caricamento
  Timer? _loadingTimer;
  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = const [
    "Sto sognando la tua storia...✨",
    "Mescolando un po' di magia...🪄",
    "Consultando le stelle narranti...🌟",
    "Cercando le parole giuste...📖",
    "Accendendo la fantasia...💡",
    "Quasi pronto per l'avventura! 🚀",
    "Shhh... l'ispirazione sta arrivando!🤫",
    "Un pizzico di polvere di fata...🧚",
    "Tessendo la trama del racconto...🧶",
  ];

  // Avvia il timer per cambiare i messaggi di caricamento
  void _startLoadingTimer() {
    _loadingTimer?.cancel(); // Cancella timer precedenti per sicurezza
    setState(() {
      _currentMessageIndex = 0; // Resetta indice
    });
    _loadingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        // Controlla se il widget è ancora attivo
        timer.cancel();
        return;
      }
      setState(() {
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  // Ferma il timer quando il caricamento è completo
  void _stopLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  // Opzioni per i filtri a bottone
  final List<String> _ageRanges = ['2-5 anni', '6-8 anni', '9-12 anni'];
  final List<String> _lengths = ['breve', 'media', 'lunga'];
  final List<String> _themes = [
    'animali',
    'avventura',
    'magia',
    'amicizia',
    'amore',
    'natura',
    'famiglia',
    'fantasia',
    'crescita personale',
    'fiaba classica',
  ];
  final List<String> _characters = [
    'orsetto',
    'principessa',
    'supereroe',
    'bambino/a curioso/a',
    'coniglietto',
    'volpe astuta',
    'draghetto',
    'fatina',
    'folletto dispettoso',
    'unicorno magico',
  ];
  final List<String> _settings = [
    'bosco incantato',
    'castello maestoso',
    'spazio siderale',
    'fattoria allegra',
    'spiaggia soleggiata',
    'città vivace',
    'mondo sottomarino',
    'giardino segreto',
    'montagne innevate',
    'isola misteriosa',
  ];
  final List<String> _emotions = [
    'gioia',
    'coraggio',
    'calma',
    'curiosità',
    'gentilezza',
    'meraviglia',
    'speranza',
    'empatia',
    'determinazione',
    'gratitudine',
  ];

  // Creiamo classi per i temi complessi e le morali, in modo da non avere valori duplicati
  final List<ComplexThemeOption> _complexThemes = [
    ComplexThemeOption(null, 'Nessuno'),
    ComplexThemeOption('superare la paura', 'Superare la paura'),
    ComplexThemeOption(
      'l\'importanza dell\'amicizia',
      'L\'importanza dell\'amicizia',
    ),
    ComplexThemeOption('accettare le differenze', 'Accettare le differenze'),
    ComplexThemeOption('essere pazienti', 'Essere pazienti'),
    ComplexThemeOption('il valore della famiglia', 'Il valore della famiglia'),
    ComplexThemeOption('credere in se stessi', 'Credere in se stessi'),
    ComplexThemeOption(
      'il potere dell\'immaginazione',
      'Il potere dell\'immaginazione',
    ),
    ComplexThemeOption('rispettare la natura', 'Rispettare la natura'),
    ComplexThemeOption(
      'l\'importanza di condividere',
      'L\'importanza di condividere',
    ),
  ];

  final List<MoralOption> _morals = [
    MoralOption(null, 'Nessuno'),
    MoralOption('imparare a condividere', 'Imparare a condividere'),
    MoralOption('essere gentili con tutti', 'Essere gentili con tutti'),
    MoralOption('l\'onestà premia sempre', 'L\'onestà premia sempre'),
    MoralOption('l\'importanza di ascoltare', 'L\'importanza di ascoltare'),
    MoralOption('ogni persona è speciale', 'Ogni persona è speciale'),
    MoralOption('insieme siamo più forti', 'Insieme siamo più forti'),
    MoralOption(
      'non giudicare dalle apparenze',
      'Non giudicare dalle apparenze',
    ),
    MoralOption('il vero amore supera tutto', 'Il vero amore supera tutto'),
    MoralOption(
      'la perseveranza porta al successo',
      'La perseveranza porta al successo',
    ),
  ];

  // Teniamo traccia degli oggetti selezionati
  ComplexThemeOption? _selectedComplexThemeOption;
  MoralOption? _selectedMoralOption;

  // Aggiungi icone per ogni categoria
  final Map<String, IconData> _categoryIcons = {
    'età': FontAwesomeIcons.child,
    'lunghezza': FontAwesomeIcons.ruler,
    'tema': FontAwesomeIcons.wandMagicSparkles,
    'personaggio': FontAwesomeIcons.userAstronaut,
    'ambientazione': FontAwesomeIcons.tree,
    'emozione': FontAwesomeIcons.faceSmile,
    'tema complesso': FontAwesomeIcons.brain,
    'morale': FontAwesomeIcons.heartCircleCheck,
  };

  @override
  void initState() {
    super.initState();
    // Inizializziamo le opzioni con i valori di default
    _selectedComplexThemeOption = _complexThemes.first;
    _selectedMoralOption = _morals.first;
  }

  @override
  void dispose() {
    // Pulizia del controller quando il widget viene distrutto
    _childNameController.dispose();
    _loadingTimer?.cancel(); // Assicurati di cancellare il timer
    super.dispose();
  }

  // Funzione per chiamare l'API
  // Creiamo un'istanza dell'ApiService che verrà riutilizzata
  final ApiService _apiService = ApiService();

  Future<void> _generateStory() async {
    // Validazione di base: assicurati che i campi obbligatori siano selezionati
    if (_selectedAgeRange == null ||
        (_selectedLength == null &&
            !_isInteractiveMode) || // Lunghezza non necessaria per modalità interattiva
        _selectedTheme == null ||
        _selectedCharacter == null ||
        _selectedSetting == null ||
        _selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Per favore, seleziona tutte le opzioni obbligatorie.'),
        ),
      );
      return;
    }

    // Attiva l'indicatore di caricamento e il timer dei messaggi
    setState(() {
      _isLoading = true;
    });
    _startLoadingTimer();

    final apiService = ApiService();
    try {
      // Ottieni il nome del bambino (se presente)
      final childName =
          _childNameController.text.trim().isNotEmpty
              ? _childNameController.text.trim()
              : null;

      // Determina quale API chiamare in base alla modalità selezionata
      if (_isInteractiveMode) {
        // Inizia una storia interattiva
        final storyData = await apiService.startInteractiveStory(
          ageRange: _selectedAgeRange!,
          theme: _selectedTheme!,
          mainCharacter: _selectedCharacter!,
          setting: _selectedSetting!,
          emotion: _selectedEmotion!,
          complexTheme: _selectedComplexThemeOption?.value,
          moral: _selectedMoralOption?.value,
          childName: childName,
        );

        // Disattiva l'indicatore di caricamento
        _stopLoadingTimer();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Naviga alla schermata di avventura testuale passando i dati iniziali
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => StoryAdventureScreen(
                    initialStoryData: storyData,
                    storyFilters: {
                      'ageRange': _selectedAgeRange!,
                      'theme': _selectedTheme!,
                      'mainCharacter': _selectedCharacter!,
                      'setting': _selectedSetting!,
                      'emotion': _selectedEmotion!,
                      if (_selectedComplexThemeOption?.value != null)
                        'complexTheme': _selectedComplexThemeOption!.value!,
                      if (_selectedMoralOption?.value != null)
                        'moral': _selectedMoralOption!.value!,
                      if (childName != null) 'childName': childName,
                    },
                  ),
            ),
          );
        }
      } else {
        // Genera una storia classica
        final story = await apiService.generateStory(
          ageRange: _selectedAgeRange!,
          storyLength: _selectedLength!,
          theme: _selectedTheme!,
          mainCharacter: _selectedCharacter!,
          setting: _selectedSetting!,
          emotion: _selectedEmotion!,
          complexTheme: _selectedComplexThemeOption?.value,
          moral: _selectedMoralOption?.value,
          childName: childName,
        );

        // Disattiva l'indicatore di caricamento
        _stopLoadingTimer();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Naviga alla schermata di visualizzazione passando la storia
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryDisplayScreen(storyText: story),
            ),
          );
        }
      }
    } catch (e) {
      // Disattiva l'indicatore di caricamento in caso di errore
      _stopLoadingTimer();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Mostra un messaggio appropriato in base al tipo di errore
      if (mounted) {
        String errorMessage = 'Errore durante la generazione della storia';

        // Verifica se l'errore è dovuto all'annullamento della richiesta
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('ClientException')) {
          errorMessage = 'Generazione storia annullata';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
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
              // Contenuto principale della schermata (sempre visibile)
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con animazione
                    _buildHeader(context),

                    const SizedBox(height: 8),

                    // Linea colorata decorativa
                    Container(
                          height: 4,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: -0.5, end: 0.0),

                    const SizedBox(height: 24),

                    // Form per la creazione
                    Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Sezione 1: Dettagli Base
                          _buildSectionHeader(
                            context,
                            title: 'Dettagli Base',
                            icon: FontAwesomeIcons.wandMagicSparkles,
                            color: colorScheme.primary,
                            centered: true,
                          ),

                          const SizedBox(height: 16),

                          // Age range & Story Length come bottoni
                          _buildFilterLabel(
                            'Fascia d\'età',
                            _categoryIcons['età']!,
                            colorScheme.primary,
                          ),
                          _buildFilterButtonGroup(
                            _ageRanges,
                            _selectedAgeRange,
                            (value) =>
                                setState(() => _selectedAgeRange = value),
                            colorScheme.primary,
                            400,
                          ),

                          const SizedBox(height: 16),

                          // Campo per il nome del bambino
                          _buildFilterLabel(
                            'Nome del Bambino (opzionale)',
                            FontAwesomeIcons.child,
                            colorScheme.secondary,
                          ),
                          Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TextFormField(
                                  controller: _childNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Inserisci il nome...',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.secondary
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.secondary
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: colorScheme.secondary,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.secondary
                                        .withOpacity(0.05),
                                    prefixIcon: Icon(
                                      FontAwesomeIcons.solidUser,
                                      size: 16,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 600.ms)
                              .slideX(begin: 0.05, end: 0),

                          const SizedBox(height: 24),

                          // Switch per attivare la modalità interattiva
                          Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: SwitchListTile(
                                      title: const Text(
                                        'Storia Interattiva',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Genera una storia a bivi con scelte',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      secondary: Icon(
                                        FontAwesomeIcons.road,
                                        color: colorScheme.secondary,
                                        size: 18,
                                      ),
                                      value: _isInteractiveMode,
                                      activeColor: colorScheme.primary,
                                      onChanged: (value) {
                                        setState(() {
                                          _isInteractiveMode = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 700.ms)
                              .slideX(begin: 0.05, end: 0),

                          // Sezione 2: Dettagli Storia
                          _buildSectionHeader(
                            context,
                            title: 'Dettagli Storia',
                            icon: FontAwesomeIcons.bookOpen,
                            color: colorScheme.secondary,
                            centered: true,
                          ),

                          const SizedBox(height: 16),

                          // Mostra la selezione della lunghezza solo se non è in modalità interattiva
                          if (!_isInteractiveMode) ...[
                            _buildFilterLabel(
                              'Lunghezza Storia',
                              _categoryIcons['lunghezza']!,
                              colorScheme.secondary,
                            ),
                            _buildFilterButtonGroup(
                              _lengths,
                              _selectedLength,
                              (value) =>
                                  setState(() => _selectedLength = value),
                              colorScheme.secondary,
                              600,
                            ),

                            const SizedBox(height: 16),
                          ],

                          _buildFilterLabel(
                            'Tema Storia',
                            _categoryIcons['tema']!,
                            colorScheme.secondary,
                          ),
                          _buildFilterButtonGroup(
                            _themes,
                            _selectedTheme,
                            (value) => setState(() => _selectedTheme = value),
                            colorScheme.secondary,
                            600,
                          ),

                          const SizedBox(height: 16),

                          _buildFilterLabel(
                            'Personaggio Principale',
                            _categoryIcons['personaggio']!,
                            colorScheme.secondary,
                          ),
                          _buildFilterButtonGroup(
                            _characters,
                            _selectedCharacter,
                            (value) =>
                                setState(() => _selectedCharacter = value),
                            colorScheme.secondary,
                            700,
                          ),

                          const SizedBox(height: 16),

                          _buildFilterLabel(
                            'Ambientazione',
                            _categoryIcons['ambientazione']!,
                            colorScheme.secondary,
                          ),
                          _buildFilterButtonGroup(
                            _settings,
                            _selectedSetting,
                            (value) => setState(() => _selectedSetting = value),
                            colorScheme.secondary,
                            800,
                          ),

                          const SizedBox(height: 16),

                          _buildFilterLabel(
                            'Emozione Prevalente',
                            _categoryIcons['emozione']!,
                            colorScheme.secondary,
                          ),
                          _buildFilterButtonGroup(
                            _emotions,
                            _selectedEmotion,
                            (value) => setState(() => _selectedEmotion = value),
                            colorScheme.secondary,
                            900,
                          ),

                          const SizedBox(height: 24),

                          // Sezione 3: Opzioni Avanzate con espansione
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isAdvancedOptionsExpanded =
                                    !_isAdvancedOptionsExpanded;
                              });
                            },
                            child: _buildSectionHeader(
                              context,
                              title: 'Opzioni Avanzate',
                              icon: FontAwesomeIcons.pencilRuler,
                              color: colorScheme.tertiary,
                              tag: 'Opzionale',
                              trailingIcon: Icon(
                                _isAdvancedOptionsExpanded
                                    ? FontAwesomeIcons.chevronUp
                                    : FontAwesomeIcons.chevronDown,
                                size: 16,
                                color: colorScheme.tertiary,
                              ),
                              centered: true,
                            ),
                          ),

                          AnimatedCrossFade(
                            firstChild: const SizedBox(height: 0),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),

                                _buildFilterLabel(
                                  'Tema Complesso',
                                  _categoryIcons['tema complesso']!,
                                  colorScheme.tertiary,
                                ),
                                _buildComplexThemeButtonGroup(
                                  _complexThemes,
                                  _selectedComplexThemeOption,
                                  (value) => setState(
                                    () => _selectedComplexThemeOption = value,
                                  ),
                                  colorScheme.tertiary,
                                  1000,
                                ),

                                const SizedBox(height: 16),

                                _buildFilterLabel(
                                  'Morale della Storia',
                                  _categoryIcons['morale']!,
                                  colorScheme.tertiary,
                                ),
                                _buildMoralButtonGroup(
                                  _morals,
                                  _selectedMoralOption,
                                  (value) => setState(
                                    () => _selectedMoralOption = value,
                                  ),
                                  colorScheme.tertiary,
                                  1100,
                                ),
                              ],
                            ),
                            crossFadeState:
                                _isAdvancedOptionsExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),

                          const SizedBox(height: 32),

                          // Pulsante di generazione con effetti
                          SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Mostra un annuncio prima di generare la storia
                                    // Prima precarichiamo l'annuncio
                                    AdService().preloadAd().then((_) {
                                      // Piccolo ritardo per assicurarsi che l'annuncio sia caricato
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () {
                                          AdService().showInterstitialAd().then(
                                            (_) {
                                              _generateStory();
                                            },
                                          );
                                        },
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.wandSparkles,
                                    size: 20,
                                  ),
                                  label: const Text('Genera Storia Magica'),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    textStyle: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 1200.ms)
                              .slideY(begin: 0.2, end: 0)
                              .shimmer(delay: 1800.ms, duration: 1800.ms),

                          const SizedBox(height: 16),

                          // Testo informativo
                          Center(
                            child: Text(
                              '✨ Le storie sono uniche, create appositamente per te',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ).animate().fadeIn(delay: 1400.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Overlay di caricamento con animazione Lottie
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Animazione Lottie
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Lottie.asset(
                                    'assets/loading.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Messaggio principale
                                Text(
                                  _isInteractiveMode
                                      ? 'Creazione Storia Interattiva'
                                      : 'Creazione Storia Magica',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 12),

                                // Messaggi rotanti
                                Text(
                                  _loadingMessages[_currentMessageIndex],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fadeIn(duration: 500.ms),

                                const SizedBox(height: 24),

                                // Dettagli della storia
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLoadingDetail(
                                        context,
                                        'Tema: ${_selectedTheme?.capitalize() ?? ""}',
                                        FontAwesomeIcons.wandMagicSparkles,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLoadingDetail(
                                        context,
                                        'Protagonista: ${_selectedCharacter?.capitalize() ?? ""}',
                                        FontAwesomeIcons.userAstronaut,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildLoadingDetail(
                                        context,
                                        'Ambientazione: ${_selectedSetting?.capitalize() ?? ""}',
                                        FontAwesomeIcons.tree,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Pulsante Annulla
                                ElevatedButton.icon(
                                      onPressed: () {
                                        // Cancella il timer
                                        _stopLoadingTimer();
                                        // Annulla la richiesta API usando l'istanza esistente
                                        _apiService.cancelRequests();
                                        // Disattiva l'indicatore di caricamento
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Annulla',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideY(begin: 0.5, end: 0),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 400.ms,
                          ),
                    ),
                  ),
                ),

              const CustomBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            'Crea la Tua Storia',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: Text(
            'Personalizza tutti gli elementi della storia',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    String? tag,
    Widget? trailingIcon,
    bool centered = false,
  }) {
    final theme = Theme.of(context);

    if (centered) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (tag != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                tag,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
          if (trailingIcon != null) ...[
            const SizedBox(height: 4),
            trailingIcon,
          ],
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (tag != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              tag,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
        if (trailingIcon != null) ...[const Spacer(), trailingIcon],
      ],
    );
  }

  Widget _buildFilterLabel(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtonGroup(
    List<String> options,
    String? selectedValue,
    Function(String) onSelected,
    Color color,
    int delay,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((option) {
            final isSelected = option == selectedValue;
            return AnimatedBuilder(
              animation: Listenable.merge(
                [],
              ), // Solo per forzare il rebuild quando cambia isSelected
              builder: (context, _) {
                return InkWell(
                      onTap: () => onSelected(option),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          option.capitalize(),
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: delay.ms)
                    .scale(begin: const Offset(0.95, 0.95));
              },
            );
          }).toList(),
    );
  }

  Widget _buildComplexThemeButtonGroup(
    List<ComplexThemeOption> options,
    ComplexThemeOption? selectedOption,
    Function(ComplexThemeOption) onSelected,
    Color color,
    int delay,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((option) {
            final isSelected = option.label == selectedOption?.label;
            return AnimatedBuilder(
              animation: Listenable.merge(
                [],
              ), // Solo per forzare il rebuild quando cambia isSelected
              builder: (context, _) {
                return InkWell(
                      onTap: () => onSelected(option),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: delay.ms)
                    .scale(begin: const Offset(0.95, 0.95));
              },
            );
          }).toList(),
    );
  }

  Widget _buildMoralButtonGroup(
    List<MoralOption> options,
    MoralOption? selectedOption,
    Function(MoralOption) onSelected,
    Color color,
    int delay,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((option) {
            final isSelected = option.label == selectedOption?.label;
            return AnimatedBuilder(
              animation: Listenable.merge(
                [],
              ), // Solo per forzare il rebuild quando cambia isSelected
              builder: (context, _) {
                return InkWell(
                      onTap: () => onSelected(option),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: delay.ms)
                    .scale(begin: const Offset(0.95, 0.95));
              },
            );
          }).toList(),
    );
  }

  // Widget per visualizzare i dettagli durante il caricamento
  Widget _buildLoadingDetail(BuildContext context, String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

// Estensione per mettere la prima lettera maiuscola (opzionale ma carina)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
