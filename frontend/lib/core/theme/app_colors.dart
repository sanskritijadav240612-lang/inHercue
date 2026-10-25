import 'package:flutter/material.dart';

/// Centralized color palette for inHercue.
/// Directly mirrors the original CSS design tokens defined in src/index.css.
class AppColors {
  AppColors._();

  // Core Canvas & Surfaces
  static const Color ivory = Color(0xFFF9F6F0); // --ivory: main background
  static const Color paper = Color(
    0xFFFFFDF9,
  ); // --paper: card & surface background

  // Brand Plum & Rose
  static const Color plum = Color(
    0xFF432B3D,
  ); // --plum: primary brand & dark headings
  static const Color plumSoft = Color(
    0xFF69505F,
  ); // --plum-soft: secondary text & subheadings
  static const Color plumHover = Color(
    0xFF56364E,
  ); // Plum button active/hover state
  static const Color plumLight = Color(
    0xFFE9E1ED,
  ); // Light plum pastel card background
  static const Color rose = Color(
    0xFFC8898F,
  ); // --rose: primary accent & brand rose
  static const Color roseLight = Color(
    0xFFF2E2E0,
  ); // --rose-light: soft pink background & highlights

  // Accents: Sage & Gold
  static const Color sage = Color(
    0xFF849B87,
  ); // --sage: wellness, natural green
  static const Color sageLight = Color(
    0xFFE5EBE2,
  ); // --sage-light: light green card background
  static const Color gold = Color(0xFFB89561); // --gold: warm amber
  static const Color goldLight = Color(
    0xFFF1E8D7,
  ); // --gold-light: light gold badge & card background

  // Text, Lines & Borders
  static const Color ink = Color(0xFF33282F); // --ink: primary dark text
  static const Color muted = Color(
    0xFF786D73,
  ); // --muted: secondary / helper text
  static const Color line = Color(
    0xFFE6DDD8,
  ); // --line: subtle divider & card borders

  // Emergency & Urgent Care
  static const Color danger = Color(
    0xFFA64D54,
  ); // --danger: emergency red & urgent alert text
  static const Color urgentBg = Color(
    0xFFFBEFEC,
  ); // Background for urgent warning banners
  static const Color urgentBorder = Color(
    0xFFE7C6C4,
  ); // Border for urgent warning banners
  static const Color urgentIconBg = Color(
    0xFFF1D9D6,
  ); // Circular icon background for urgent warnings
}
