import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classe di utilità per gestire la responsività dell'app
class ResponsiveUtils {
  /// Calcola un valore dinamico in base alla larghezza dello schermo
  static double getResponsiveValue({
    required BuildContext context,
    required double defaultValue,
    required double smallScreenValue,
    double breakpoint = 360.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < breakpoint ? smallScreenValue : defaultValue;
  }

  /// Restituisce un FontSize adatto in base alle dimensioni dello schermo
  static double getResponsiveFontSize({
    required BuildContext context,
    required double defaultSize,
    double? minSize,
    double? maxSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Valori di riferimento per lo scaling
    const referenceWidth = 375.0; // Larghezza di riferimento (iPhone X)

    // Calcoliamo un fattore di scaling basato sulla larghezza dello schermo
    double scaleFactor = screenWidth / referenceWidth;

    // Limitiamo il fattore di scaling per evitare testi troppo piccoli o troppo grandi
    scaleFactor = scaleFactor.clamp(0.8, 1.2);

    // Calcoliamo la dimensione del font basata sul fattore di scaling
    double calculatedSize = defaultSize * scaleFactor;

    // Applichiamo limiti se specificati
    if (minSize != null && calculatedSize < minSize) {
      return minSize;
    }
    if (maxSize != null && calculatedSize > maxSize) {
      return maxSize;
    }

    return calculatedSize;
  }

  /// Calcola il padding sicuro in base alle dimensioni di sicurezza del dispositivo
  static EdgeInsets getSafePadding(
    BuildContext context, {
    double horizontalBase = 24.0,
    double verticalBase = 24.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final viewPadding = mediaQuery.viewPadding;
    final screenWidth = mediaQuery.size.width;

    // Calcoliamo il padding orizzontale in base alla larghezza dello schermo
    final horizontalPadding =
        screenWidth < 360 ? horizontalBase - 8 : horizontalBase;

    return EdgeInsets.fromLTRB(
      math.max(horizontalPadding, viewPadding.left),
      math.max(verticalBase, viewPadding.top),
      math.max(horizontalPadding, viewPadding.right),
      math.max(verticalBase, viewPadding.bottom),
    );
  }
}
