/// Costanti dell'applicazione per una gestione centralizzata
class AppConstants {
  /// Dimensioni e misure
  static const double kDefaultPadding = 24.0;
  static const double kSmallPadding = 16.0;
  static const double kTinyPadding = 8.0;

  /// Border radius
  static const double kDefaultBorderRadius = 16.0;
  static const double kLargeBorderRadius = 20.0;
  static const double kSmallBorderRadius = 12.0;
  static const double kRoundBorderRadius = 50.0;

  /// Elevazione
  static const double kDefaultElevation = 2.0;
  static const double kCardElevation = 4.0;

  /// Icon sizes
  static const double kSmallIconSize = 16.0;
  static const double kDefaultIconSize = 24.0;
  static const double kLargeIconSize = 32.0;

  /// Durata animazioni
  static const Duration kDefaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration kSlowAnimationDuration = Duration(milliseconds: 600);
  static const Duration kQuickAnimationDuration = Duration(milliseconds: 150);

  /// Dimensioni schermo di riferimento (per calcoli responsive)
  static const double kReferenceScreenWidth = 375.0; // iPhone X width
  static const double kReferenceScreenHeight = 812.0; // iPhone X height

  /// Breakpoints per responsive design
  static const double kMobileBreakpoint = 360.0;
  static const double kTabletBreakpoint = 600.0;

  /// Font size
  static const double kHeadingFontSize = 24.0;
  static const double kSubheadingFontSize = 18.0;
  static const double kBodyFontSize = 16.0;
  static const double kSmallFontSize = 14.0;
  static const double kCaptionFontSize = 12.0;

  /// Opacità
  static const double kActiveOpacity = 1.0;
  static const double kInactiveOpacity = 0.6;
  static const double kDisabledOpacity = 0.3;

  /// Layout limits
  static const double kMaxContentWidth =
      600.0; // Larghezza massima del contenuto
}
