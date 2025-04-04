import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MagicParticles extends StatefulWidget {
  final int numberOfParticles;

  const MagicParticles({Key? key, this.numberOfParticles = 30})
    : super(key: key);

  @override
  State<MagicParticles> createState() => _MagicParticlesState();
}

class _MagicParticlesState extends State<MagicParticles>
    with SingleTickerProviderStateMixin {
  final List<ParticleModel> particles = [];
  final Random random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Utilizzo di un singolo controller di animazione per tutte le particelle
    // anziché un controller per ogni particella, per migliorare le prestazioni
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Inizializziamo le particelle solo quando conosciamo le dimensioni del layout
        if (particles.isEmpty) {
          List.generate(widget.numberOfParticles, (index) {
            particles.add(
              ParticleModel(
                random,
                constraints.maxWidth,
                constraints.maxHeight,
              ),
            );
          });
        }

        return RepaintBoundary(
          // Avvolge l'animazione in un RepaintBoundary per migliori prestazioni
          child: Stack(
            children:
                particles.map((particle) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Usiamo un singolo controller e lo adattiamo alla velocità di ogni particella
                      final progress =
                          (_controller.value * particle.speed) % 1.0;
                      final xPosition =
                          particle.initialX +
                          sin(progress * particle.cycles * 2 * pi) *
                              particle.movementRadius;
                      final yPosition =
                          particle.initialY - progress * constraints.maxHeight;

                      // Se la particella esce dallo schermo, la resettiamo
                      if (yPosition < 0) {
                        particle.reset(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        // Posizioniamo la particella resettata alla base dello schermo
                        particle.initialY = constraints.maxHeight;
                      }

                      return Positioned(
                        left: xPosition,
                        top: yPosition,
                        child: _buildParticle(particle, progress),
                      );
                    },
                  );
                }).toList(),
          ),
        ).animate().fadeIn(
          duration: 600.ms,
        ); // Durata di fadeIn ridotta da 800ms a 600ms
      },
    );
  }

  Widget _buildParticle(ParticleModel particle, double progress) {
    return particle.isButterfly
        ? _buildButterfly(particle, progress)
        : _buildGlowingDot(particle, progress);
  }

  Widget _buildGlowingDot(ParticleModel particle, double progress) {
    return Container(
      width: particle.size,
      height: particle.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: particle.color.withOpacity(0.6 + (progress * 0.4)),
        boxShadow: [
          BoxShadow(
            color: particle.color.withOpacity(0.3),
            blurRadius: particle.size * 2,
            spreadRadius: particle.size * 0.5,
          ),
        ],
      ),
    );
  }

  Widget _buildButterfly(ParticleModel particle, double progress) {
    // Calcoli semplificati per la rotazione e lo scaling per migliori prestazioni
    final rotation = sin(progress * 10) * 0.5;
    final scale = 0.8 + (sin(progress * 8) * 0.2);

    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: scale,
        child: Icon(
          Icons.flutter_dash,
          size: particle.size * 1.8,
          color: particle.color.withOpacity(0.6 + (progress * 0.4)),
        ),
      ),
    );
  }
}

class ParticleModel {
  late double initialX;
  late double initialY;
  late double movementRadius;
  late double speed;
  late double size;
  late Color color;
  late double cycles;
  late bool isButterfly;

  final Random random;

  ParticleModel(this.random, double screenWidth, double screenHeight) {
    reset(screenWidth, screenHeight);
  }

  void reset(double screenWidth, double screenHeight) {
    initialX = random.nextDouble() * screenWidth;
    // Distribuiamo le particelle su tutta l'altezza invece di solo dal fondo
    initialY = random.nextDouble() * screenHeight;
    movementRadius =
        20 + random.nextDouble() * 30; // Ridotto il movimento laterale
    speed = 0.1 + random.nextDouble() * 0.1; // Velocità più consistente
    size =
        3 +
        random.nextDouble() *
            4; // Dimensione più piccola per prestazioni migliori
    cycles = 2 + random.nextDouble() * 2; // Cicli ridotti
    isButterfly = random.nextDouble() > 0.7; // Minor numero di farfalle (30%)

    final colorOptions = [
      const Color(0xFFE384FF), // Rosa
      const Color(0xFF86B6F6), // Azzurro
      const Color(0xFFFFD28F), // Arancione chiaro
      const Color(0xFFB5FF7D), // Verde chiaro
      const Color(0xFFFFEB3B), // Giallo
    ];

    color = colorOptions[random.nextInt(colorOptions.length)];
  }
}
