import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  List<Color> colorPalette = [
    primaryPurple,
    secondaryBlue,
    accentYellow,
    accentGreen,
    accentRed,
  ];

  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color secondaryBlue = Color(0xFF4D96FF);
  static const Color accentYellow = Color(0xFFFFC83D);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFFF6B6B);

 static const Color bgLight = Color(0xFFF6F7FB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnColor = Colors.white;

  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(90, 178, 178, 228),
    primaryColor: const Color.fromARGB(255, 163, 159, 236),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
