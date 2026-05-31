// constants/app_colors.dart
// Central place for all colors used in UJ ISMS
// Change colors here and they update everywhere in the app

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary     = Color(0xFF062C2B); // Deep dark teal
  static const Color secondary   = Color(0xFF0F766E); // Medium teal
  static const Color accent      = Color(0xFF14B8A6); // Light teal accent

  // Background
  static const Color background  = Color(0xFFF4F7F6); // Soft off-white
  static const Color cardBg      = Colors.white;

  // Status colors
  static const Color pending     = Color(0xFFFEF3C7); // Amber light
  static const Color pendingText = Color(0xFFB45309);
  static const Color inProgress  = Color(0xFFE0F2FE); // Sky light
  static const Color inProgressText = Color(0xFF0369A1);
  static const Color completed   = Color(0xFFD1FAE5); // Emerald light
  static const Color completedText  = Color(0xFF047857);
  static const Color cancelled   = Color(0xFFFFE4E6); // Rose light
  static const Color cancelledText  = Color(0xFFBE123C);

  // Priority colors
  static const Color urgent      = Color(0xFFFFE4E6);
  static const Color urgentText  = Color(0xFFBE123C);
  static const Color high        = Color(0xFFFFF7ED);
  static const Color highText    = Color(0xFFC2410C);
  static const Color normal      = Color(0xFFCCFBF1);
  static const Color normalText  = Color(0xFF0F766E);

  // Text shades
  static const Color textDark    = Color(0xFF0C2B27);
  static const Color textMid     = Color(0xFF4B5F73);
  static const Color textLight   = Colors.black54;

  // Border
  static const Color border      = Color(0xFFE1E8F0);
}
