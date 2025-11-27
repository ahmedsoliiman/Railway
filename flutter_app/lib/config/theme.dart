import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  static const Color successColor = Color(0xFF48BB78);
  static const Color dangerColor = Color(0xFFF56565);
  static const Color warningColor = Color(0xFFED8936);
  static const Color darkColor = Color(0xFF2D3748);
  static const Color grayColor = Color(0xFF718096);
  static const Color lightGrayColor = Color(0xFFE2E8F0);
  static const Color bgColor = Color(0xFFF7FAFC);
  static const Color whiteColor = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Theme
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: darkColor,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: darkColor,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: darkColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: darkColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: darkColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: darkColor,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: darkColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: darkColor,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: grayColor,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: whiteColor,
      background: bgColor,
      error: dangerColor,
    ),
    textTheme: textTheme,
    scaffoldBackgroundColor: bgColor,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: whiteColor,
      foregroundColor: darkColor,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGrayColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGrayColor, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dangerColor, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: grayColor,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: grayColor,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: whiteColor,
    ),
  );
}
