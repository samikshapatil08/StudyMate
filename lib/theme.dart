import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors (Keep as is)
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color secondaryBlue = Color(0xFF4D96FF);
  static const Color accentYellow = Color(0xFFFFC83D);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFFF6B6B);

  // Light Mode Colors
  static const Color bgLight = Color(0xFFF6F7FB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnColor = Colors.white;

  // Dark Mode Colors
  static const Color bgDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);

  List<Color> colorPalette = [
    primaryPurple,
    secondaryBlue,
    accentYellow,
    accentGreen,
    accentRed,
  ];

  // 🌞 LIGHT THEME
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primaryPurple,
      cardColor: cardWhite,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
    );
  }

  // 🌙 DARK THEME
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryPurple, // Brand color remains
      cardColor: cardDark,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondaryDark),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimaryDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // Ensure dialogs match
      dialogTheme: DialogThemeData(backgroundColor: cardDark)
    );
  }
}