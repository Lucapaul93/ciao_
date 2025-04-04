import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette moderna e vibrante
  static const primaryLight = Color(0xFF5E60CE); // Viola brillante
  static const secondaryLight = Color(0xFF64DFDF); // Turchese vibrante
  static const accentLight = Color(0xFFFF7A8A); // Rosa coral
  static const backgroundLight = Color(0xFFF8F9FE); // Bianco azzurrato leggero
  static const textLight = Color(0xFF2D3142); // Grigio blu scuro
  static const surfaceLight = Color(0xFFFFFFFF); // Bianco puro

  // Palette dark mode con colori vibranti ma adatti al tema scuro
  static const primaryDark = Color(0xFF6C63FF); // Viola elettrico
  static const secondaryDark = Color(0xFF56CBD4); // Turchese profondo
  static const accentDark = Color(0xFFFF6B78); // Rosa vivace
  static const backgroundDark = Color(0xFF1A1B2E); // Blu scuro
  static const textDark = Color(0xFFF9FAFC); // Bianco perlato
  static const surfaceDark = Color(0xFF252A40); // Blu grigio scuro

  // Font moderni e leggibili
  static final fontHeading = GoogleFonts.montserrat(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static final fontBody = GoogleFonts.inter(letterSpacing: 0.2);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      tertiary: accentLight,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: textLight,
      onSurface: textLight,
    ),
    textTheme: TextTheme(
      displayLarge: fontHeading.copyWith(fontSize: 32, color: textLight),
      displayMedium: fontHeading.copyWith(fontSize: 24, color: textLight),
      titleLarge: fontHeading.copyWith(fontSize: 20, color: textLight),
      titleMedium: fontHeading.copyWith(fontSize: 16, color: textLight),
      bodyLarge: fontBody.copyWith(fontSize: 16, color: textLight),
      bodyMedium: fontBody.copyWith(fontSize: 14, color: textLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: fontHeading.copyWith(fontSize: 16, letterSpacing: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      labelStyle: TextStyle(color: textLight.withOpacity(0.7)),
      prefixIconColor: primaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surfaceLight,
      clipBehavior: Clip.antiAlias,
    ),
    iconTheme: IconThemeData(color: primaryLight, size: 24),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEAEBF2),
      thickness: 1,
      space: 24,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textLight.withOpacity(0.5),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLight,
      indicatorColor: primaryLight.withOpacity(0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return fontBody.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryLight,
          );
        }
        return fontBody.copyWith(
          fontSize: 12,
          color: textLight.withOpacity(0.7),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: primaryLight, size: 24);
        }
        return IconThemeData(color: textLight.withOpacity(0.7), size: 24);
      }),
      elevation: 0,
      height: 72,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryDark,
      tertiary: accentDark,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
    ),
    textTheme: TextTheme(
      displayLarge: fontHeading.copyWith(fontSize: 32, color: textDark),
      displayMedium: fontHeading.copyWith(fontSize: 24, color: textDark),
      titleLarge: fontHeading.copyWith(fontSize: 20, color: textDark),
      titleMedium: fontHeading.copyWith(fontSize: 16, color: textDark),
      bodyLarge: fontBody.copyWith(fontSize: 16, color: textDark),
      bodyMedium: fontBody.copyWith(fontSize: 14, color: textDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: fontHeading.copyWith(fontSize: 16, letterSpacing: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      labelStyle: TextStyle(color: textDark.withOpacity(0.7)),
      prefixIconColor: primaryDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surfaceDark,
      clipBehavior: Clip.antiAlias,
    ),
    iconTheme: IconThemeData(color: primaryDark, size: 24),
    dividerTheme: DividerThemeData(
      color: textDark.withOpacity(0.1),
      thickness: 1,
      space: 24,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textDark.withOpacity(0.5),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: primaryDark.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return fontBody.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryDark,
          );
        }
        return fontBody.copyWith(
          fontSize: 12,
          color: textDark.withOpacity(0.7),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: primaryDark, size: 24);
        }
        return IconThemeData(color: textDark.withOpacity(0.7), size: 24);
      }),
      elevation: 0,
      height: 72,
    ),
  );
}
