import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TruceTheme {
  static const Color primary = Color(0xFF00162A);
  static const Color primaryContainer = Color(0xFF0D2B45);
  static const Color tertiary = Color(0xFF001912);
  static const Color backgroundLight = Color(0xFFF7F9FF);
  static const Color backgroundDark = Color(0xFF000B14);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF00162A);
  static const Color accentGreen = Color(0xFF006B54);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        tertiary: tertiary,
        surface: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          color: primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: primary,
        primaryContainer: primaryContainer,
        tertiary: accentGreen,
        surface: backgroundDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
