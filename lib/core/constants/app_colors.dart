import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF4F8EF7);
  static const primaryDark = Color(0xFF2563EB);
  static const secondary = Color(0xFF7C3AED);
  static const accent = Color(0xFF06B6D4);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Dark theme surfaces
  static const bgDark = Color(0xFF0A0D14);
  static const surfaceDark = Color(0xFF0F1420);
  static const cardDark = Color(0xFF161C2E);
  static const card2Dark = Color(0xFF1C2338);
  static const borderDark = Color(0xFF1E2A42);

  // Light theme surfaces
  static const bgLight = Color(0xFFF0F4FF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE2E8F0);

  // Text
  static const textDark = Color(0xFFE8EAF0);
  static const textSecondaryDark = Color(0xFF8892A4);
  static const textLight = Color(0xFF1A202C);
  static const textSecondaryLight = Color(0xFF64748B);

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF4F8EF7), Color(0xFF7C3AED)];
  static const List<Color> successGradient = [Color(0xFF22C55E), Color(0xFF06B6D4)];
  static const List<Color> warmGradient = [Color(0xFFF59E0B), Color(0xFFEF4444)];
  static const List<Color> darkCardGradient = [Color(0xFF161C2E), Color(0xFF1C2338)];
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      background: AppColors.bgDark,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    ),
    // cardTheme: CardTheme(
    //   color: AppColors.cardDark,
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //     side: const BorderSide(color: AppColors.borderDark),
    //   ),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card2Dark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontFamily: 'Cairo'),
      hintStyle: const TextStyle(color: AppColors.textSecondaryDark, fontFamily: 'Cairo'),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      background: AppColors.bgLight,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
      ),
    ),
    // cardTheme: CardTheme(
    //   color: AppColors.cardLight,
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //     side: const BorderSide(color: AppColors.borderLight),
    //   ),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontFamily: 'Cairo'),
      hintStyle: const TextStyle(color: AppColors.textSecondaryLight, fontFamily: 'Cairo'),
    ),
  );
}
