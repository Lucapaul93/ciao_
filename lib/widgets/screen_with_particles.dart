import 'package:flutter/material.dart';
import 'magic_particles.dart';
import '../utils/performance_utils.dart';

/// Widget wrapper che aggiunge l'effetto particelle magiche a qualsiasi schermata.
/// Può essere utilizzato per aggiungere un effetto visivo consistente in tutta l'app.
class ScreenWithParticles extends StatelessWidget {
  final Widget child;
  final int numberOfParticles;
  final String? backgroundImagePath;

  const ScreenWithParticles({
    Key? key,
    required this.child,
    this.numberOfParticles = 30,
    this.backgroundImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Immagine di sfondo se specificata
        if (backgroundImagePath != null)
          Positioned.fill(
            child: Image.asset(backgroundImagePath!, fit: BoxFit.cover),
          ),

        // Overlay semi-trasparente per migliorare la leggibilità
        if (backgroundImagePath != null)
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

        // Effetto particelle magiche (solo se abilitato)
        if (PerformanceConfig.particlesEnabled)
          Positioned.fill(
            child: MagicParticles(
              // Usa il numero specificato o quello dalle impostazioni
              numberOfParticles: PerformanceConfig.particlesCount,
            ),
          ),

        // Contenuto della schermata
        child,
      ],
    );
  }
}
