import 'package:flutter/material.dart';

class AppColors {
  // --- Light Mode (Basic Purple Theme) ---
  // Primary (60%) - Used for interactive icons, names, static text, settings, bars
  static const Color primaryLight = Color(0xFF23113E);
  // Secondary (30%) - Small/static buttons, chat bubbles, free/discount badges
  static const Color secondaryLight = Color(0xFF6D3A96);
  // Neutral (10%) - Small text, message dates, game details, news body
  static const Color neutralLight = Color(0xFF151515);

  // --- Dark Mode (Basic Gold Theme) ---
  // Primary (60%) - Same as purple but for dark mode (Gold)
  static const Color primaryDark = Color.fromRGBO(204, 175, 44, 1);
  // Secondary (30%) - Small/static buttons, chat bubbles, badges
  static const Color secondaryDark = Color.fromRGBO(55, 2, 98, 1);
  // Neutral (10%) - Small text, message dates, game details, news body (Off-white)
  static const Color neutralDark = Color.fromRGBO(238, 226, 210, 1);

  // Background and Surfaces
  static const Color backgroundLight = Color(
    0xFFF8F9FA,
  ); // Very light gray for contrast
  static const Color backgroundDark = Color.fromRGBO(20, 9, 38, 1);
  // Very dark brown/black for contrast with gold

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color.fromRGBO(
    78,
    0,
    140,
    1,
  ); // Slightly lighter than background dark

  // Functional
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}
