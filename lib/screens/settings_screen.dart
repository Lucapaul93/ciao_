import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/back_button.dart';
import '../widgets/screen_with_particles.dart';
import '../providers/theme_provider.dart';
import '../utils/performance_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Funzione per eliminare tutte le storie
  Future<void> _clearAllStories(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione Totale'),
          content: const Text(
            'Sei sicuro di voler eliminare TUTTE le storie salvate? Questa azione è irreversibile.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Elimina Tutto'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('savedStories'); // Rimuove la chiave
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutte le storie salvate sono state eliminate.'),
          ),
        );
        // Qui potresti voler forzare un aggiornamento della schermata SavedStories se è visibile
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
        );
      }
    }
  }

  // Funzione per mostrare il dialog di selezione dimensione testo
  void _showTextSizeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    double currentScale = themeProvider.textScaleFactor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dimensione Testo'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Esempio di testo',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16 * currentScale,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: currentScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: '${currentScale.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      setState(() {
                        currentScale = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('Piccolo'), const Text('Grande')],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                themeProvider.setTextScaleFactor(currentScale);
                Navigator.of(context).pop();
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  // Funzione per mostrare le informazioni sull'app
  void _showAppInfo(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.circleInfo,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text('Informazioni App'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Versione'),
                    subtitle: Text(
                      '${packageInfo.version} (${packageInfo.buildNumber})',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  const ListTile(
                    title: Text('Sviluppatore'),
                    subtitle: Text('Luca93'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  const ListTile(
                    title: Text('Copyright'),
                    subtitle: Text('© 2024 Tutti i diritti riservati'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Chiudi'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Fallback in caso di errore
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Informazioni App'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Sviluppatore'),
                    subtitle: Text('Luca93'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Copyright'),
                    subtitle: Text('© 2024 Tutti i diritti riservati'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Chiudi'),
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
    return Scaffold(
      body: SafeArea(
        child: ScreenWithParticles(
          // Uso la configurazione ottimale per il numero di particelle
          numberOfParticles: PerformanceConfig.particlesCount,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                            'Impostazioni',
                            style: Theme.of(context).textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.2, end: 0),
                    ),
                    const SizedBox(height: 20),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return ListTile(
                              leading: const Icon(FontAwesomeIcons.moon),
                              title: Text(
                                'Tema Scuro',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: 0.2, end: 0);
                      },
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                          leading: const Icon(FontAwesomeIcons.font),
                          title: Text(
                            'Dimensione Testo',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showTextSizeSelector(context),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: 0.2, end: 0),

                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return ListTile(
                              leading: const Icon(
                                FontAwesomeIcons.wandMagicSparkles,
                              ),
                              title: Text(
                                'Effetti Particelle',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: Switch(
                                value: PerformanceConfig.particlesEnabled,
                                onChanged: (value) async {
                                  await PerformanceConfig.setParticlesEnabled(
                                    value,
                                  );
                                  setState(() {});
                                },
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .slideX(begin: 0.2, end: 0);
                      },
                    ),

                    const SizedBox(height: 10),
                    ListTile(
                          leading: const Icon(
                            FontAwesomeIcons.trash,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Elimina Storie Salvate',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _clearAllStories(context),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideX(begin: 0.2, end: 0),

                    const SizedBox(height: 10),
                    ListTile(
                          leading: const Icon(
                            FontAwesomeIcons.circleInfo,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Informazioni',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showAppInfo(context),
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideX(begin: 0.2, end: 0),

                    const SizedBox(height: 20),
                    // Sezione performance avanzate
                    Text(
                      'Prestazioni Avanzate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Ottimizza le prestazioni modificando queste impostazioni se l\'app risulta lenta sul tuo dispositivo.',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  children: [
                                    Text(
                                      'Numero di particelle: ${PerformanceConfig.particlesCount}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    Slider(
                                      value:
                                          PerformanceConfig.particlesCount
                                              .toDouble(),
                                      min: 0,
                                      max: 60,
                                      divisions: 12,
                                      label:
                                          PerformanceConfig.particlesCount
                                              .toString(),
                                      onChanged: (value) async {
                                        await PerformanceConfig.setParticlesCount(
                                          value.toInt(),
                                        );
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Meno (più veloce)',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Più (più bello)',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
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
}
