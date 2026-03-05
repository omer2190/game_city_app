import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../values/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.alexandria().fontFamily,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.surfaceLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors
          .primaryLight, // Following rule of primary for clickable/names
      onSurfaceVariant:
          AppColors.neutralLight, // Following rule of neutral for small details
    ),
    textTheme: GoogleFonts.alexandriaTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.primaryLight),
        bodyMedium: TextStyle(color: AppColors.neutralLight),
        labelSmall: TextStyle(color: AppColors.neutralLight, fontSize: 11),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.cairo().fontFamily,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.surfaceDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(26, 12, 48, 1), // Darker bar for contrast
      foregroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.primaryDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.primaryDark),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      // primary: Colors.black,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.primaryDark, // Clickable items in primary
      onSurfaceVariant: AppColors.neutralDark, // Small details in neutral
    ),
    textTheme: GoogleFonts.cairoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: AppColors.primaryDark),
        bodyMedium: TextStyle(color: AppColors.primaryDark),
        labelSmall: TextStyle(color: AppColors.neutralDark, fontSize: 11),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.black,
      ),
    ),
  );
}
