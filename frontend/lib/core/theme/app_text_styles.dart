import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized typography definitions for inHercue.
/// Follows the dual-font system from the Figma design:
/// - Editorial Headings: Playfair Display (Serif, weights 500, 600)
/// - UI & Body Text: DM Sans (Sans-serif, weights 400, 500, 600)
class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // Editorial Display Headings (Playfair Display)
  // ---------------------------------------------------------------------------
  static TextStyle welcomeDisplay = GoogleFonts.playfairDisplay(
    fontSize: 54.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: AppColors.plum,
    height: 1.15,
  );

  static TextStyle screenHeading = GoogleFonts.playfairDisplay(
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    color: AppColors.plum,
    height: 1.2,
  );

  static TextStyle sectionHeading = GoogleFonts.playfairDisplay(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppColors.plum,
    height: 1.25,
  );

  static TextStyle cardHeading = GoogleFonts.playfairDisplay(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.plum,
    height: 1.3,
  );

  static TextStyle editorialCopy = GoogleFonts.playfairDisplay(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    color: AppColors.plumSoft,
    height: 1.45,
  );

  // ---------------------------------------------------------------------------
  // Body, UI Controls & Labels (DM Sans)
  // ---------------------------------------------------------------------------
  static TextStyle kicker = GoogleFonts.dmSans(
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.2,
    color: AppColors.rose,
  );

  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.55,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.4,
  );

  static TextStyle button = GoogleFonts.dmSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.rose,
  );

  static TextStyle urgentLink = GoogleFonts.dmSans(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.danger,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.danger,
  );
}
