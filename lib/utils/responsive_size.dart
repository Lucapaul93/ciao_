import 'package:flutter/material.dart';

class ResponsiveSize {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;
  static late double pixelRatio;
  static late bool isTablet;

  // Inizializza i valori
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    textScaleFactor = _mediaQueryData.textScaleFactor;
    pixelRatio = _mediaQueryData.devicePixelRatio;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    // Considera un dispositivo con larghezza > 600 come tablet
    isTablet = screenWidth > 600;
  }

  // Funzioni per ottenere misure responsive
  static double hp(double percentage) => blockSizeVertical * percentage;
  static double wp(double percentage) => blockSizeHorizontal * percentage;

  // Per i testi, dimensiona in base alla larghezza dello schermo ma con limite massimo
  static double sp(double percentage) {
    final size = blockSizeHorizontal * percentage;
    final maxSize =
        isTablet ? 24.0 : 20.0; // Dimensione massima per tablet e telefoni
    return size > maxSize ? maxSize : size;
  }

  // Calcola padding/margin proporzionali
  static EdgeInsetsGeometry padding({
    double horizontal = 0,
    double vertical = 0,
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
    double all = 0,
  }) {
    if (all > 0) {
      return EdgeInsets.all(wp(all));
    }

    return EdgeInsets.fromLTRB(
      left > 0 ? wp(left) : wp(horizontal),
      top > 0 ? hp(top) : hp(vertical),
      right > 0 ? wp(right) : wp(horizontal),
      bottom > 0 ? hp(bottom) : hp(vertical),
    );
  }

  // Dimensioni per componenti comuni
  static double get buttonHeight => hp(6.0);
  static double get cardRadius => wp(4.0);
  static double get iconSize => wp(6.0);
  static double get smallIconSize => wp(4.0);
}
