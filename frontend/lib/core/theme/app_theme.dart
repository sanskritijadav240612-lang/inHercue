import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTheme configuration for inHercue.
/// Configures Material 3 ThemeData with ivory background, plum accents, and custom typography.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.plum,
        onPrimary: Colors.white,
        secondary: AppColors.rose,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
      ),

      // Default text theme based on DM Sans
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: GoogleFonts.dmSans().fontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.plum,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.plum),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: AppColors.line, width: 1.0),
        ),
      ),

      // Input field theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.line, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.line, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13.0),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
        ),
        hintStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 14.0,
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
