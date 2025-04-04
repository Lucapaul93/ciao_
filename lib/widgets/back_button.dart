import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Verifica se è possibile tornare indietro
    final canPop = Navigator.of(context).canPop();

    // Se non è possibile tornare indietro, non mostra il pulsante
    if (!canPop) {
      return const SizedBox.shrink();
    }

    // Ottieni le dimensioni di sicurezza
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;

    return Positioned(
      // Adatta la posizione in base alla presenza di notch o fotocamera
      top: math.max(12, viewPadding.top),
      left: math.max(12, viewPadding.left),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap:
              onPressed ??
              () {
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }
              },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              FontAwesomeIcons.chevronLeft,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }
}
