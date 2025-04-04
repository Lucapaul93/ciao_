import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart'; // Importa il servizio API
import '../widgets/back_button.dart';
import '../widgets/screen_with_particles.dart'; // Importa il nuovo widget
import '../services/ad_service.dart'; // Importa il servizio per gli annunci
import 'story_display_screen.dart'; // Importa la schermata per visualizzare la storia
import 'package:lottie/lottie.dart';

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

  bool _isLoading = false; // Per mostrare un indicatore di caricamento
  bool _isAdvancedOptionsExpanded =
      false; // Per controllare l'espansione delle opzioni avanzate

  // Opzioni per i filtri a bottone
  final List<String> _ageRanges = ['2-5 anni', '6-8 anni', '9-12 anni'];
  final List<String> _lengths = ['breve', 'media', 'lunga'];
  final List<String> _themes = [
    'animali',
    'avventura',
    'magia',
    'amicizia',
    'natura',
    'fiaba classica',
  ];
  final List<String> _characters = [
    'orsetto',
    'principessa',
    'supereroe',
    'bambino/a curioso/a',
    'coniglietto',
    'volpe astuta',
  ];
  final List<String> _settings = [
    'bosco incantato',
    'castello maestoso',
    'spazio siderale',
    'fattoria allegra',
    'spiaggia soleggiata',
    'città vivace',
  ];
  final List<String> _emotions = [
    'gioia',
    'coraggio',
    'calma',
    'curiosità',
    'gentilezza',
    'meraviglia',
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
  ];

  final List<MoralOption> _morals = [
    MoralOption(null, 'Nessuno'),
    MoralOption('imparare a condividere', 'Imparare a condividere'),
    MoralOption('essere gentili con tutti', 'Essere gentili con tutti'),
    MoralOption('l\'onestà premia sempre', 'L\'onestà premia sempre'),
    MoralOption('l\'importanza di ascoltare', 'L\'importanza di ascoltare'),
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

  // Funzione per chiamare l'API
  Future<void> _generateStory() async {
    // Validazione di base: assicurati che i campi obbligatori siano selezionati
    if (_selectedAgeRange == null ||
        _selectedLength == null ||
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

    // Dialog controller
    late BuildContext dialogContext;

    // Mostra un dialogo di caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        dialogContext = ctx;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  'assets/caricamento.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Creazione storia in corso...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'La magia richiede un po\' di tempo!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.red.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  'Annulla',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 8,
        );
      },
    );

    final apiService = ApiService();
    try {
      final story = await apiService.generateStory(
        ageRange: _selectedAgeRange!,
        storyLength: _selectedLength!,
        theme: _selectedTheme!,
        mainCharacter: _selectedCharacter!,
        setting: _selectedSetting!,
        emotion: _selectedEmotion!,
        complexTheme: _selectedComplexThemeOption?.value,
        moral: _selectedMoralOption?.value,
      );

      // Chiudi il dialogo di caricamento se ancora aperto e il contesto è valido
      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();
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
    } catch (e) {
      // Chiudi il dialogo di caricamento se ancora aperto e il contesto è valido
      if (mounted && Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop();

        // Estrai il messaggio di errore dalla Exception
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.split('Exception: ')[1];
        }

        // Mostra un dialog di errore con informazioni utili
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Errore',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Non è stato possibile generare la storia:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(errorMessage, style: TextStyle(fontSize: 15)),
                  if (errorMessage.contains('Vercel') ||
                      errorMessage.contains('server') ||
                      errorMessage.contains('sovraccarico'))
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        'Il server potrebbe essere temporaneamente sovraccarico. Riprova più tardi.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Chiudi',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Riprova a generare una storia
                    _generateStory();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Riprova',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
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
              _isLoading
                  ? Center(
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Lottie.asset(
                                'assets/caricamento.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Creazione storia in corso...',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'La magia richiede un po\' di tempo!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .scale(begin: const Offset(0.9, 0.9)),
                  )
                  : SingleChildScrollView(
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

                              _buildFilterLabel(
                                'Lunghezza Storia',
                                _categoryIcons['lunghezza']!,
                                colorScheme.primary,
                              ),
                              _buildFilterButtonGroup(
                                _lengths,
                                _selectedLength,
                                (value) =>
                                    setState(() => _selectedLength = value),
                                colorScheme.primary,
                                500,
                              ),

                              const SizedBox(height: 24),

                              // Sezione 2: Elementi Narrativi
                              _buildSectionHeader(
                                context,
                                title: 'Elementi Narrativi',
                                icon: FontAwesomeIcons.bookOpen,
                                color: colorScheme.secondary,
                                centered: true,
                              ),

                              const SizedBox(height: 16),

                              _buildFilterLabel(
                                'Tema Principale',
                                _categoryIcons['tema']!,
                                colorScheme.secondary,
                              ),
                              _buildFilterButtonGroup(
                                _themes,
                                _selectedTheme,
                                (value) =>
                                    setState(() => _selectedTheme = value),
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
                                (value) =>
                                    setState(() => _selectedSetting = value),
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
                                (value) =>
                                    setState(() => _selectedEmotion = value),
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
                                        () =>
                                            _selectedComplexThemeOption = value,
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
                                        AdService().showInterstitialAd().then((
                                          _,
                                        ) {
                                          _generateStory();
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
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
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
