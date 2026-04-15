import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  
  // Neutral Palette
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);
  
  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Legacy Aliases
  static const Color designForestGreen = Color(0xFF004D40);
  static const Color designYellow = Color(0xFFFFC107);
  static const Color designWhite = Colors.white;
  static const Color designGrey = Color(0xFF64748B);
  static const Color designSurface = Colors.white;
  static const Color designBlack = Colors.black;
  static const Color designRed = Color(0xFFEF4444);
  static const Color designBlue = Color(0xFF3B82F6);
  static const Color designOrange = Color(0xFFF59E0B);
  static const Color designGreen = Color(0xFF22C55E);
  static const Color designDarkGreen = Color(0xFF00332E);
  static const Color designMint = Color(0xFFE0F2F1);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textInversePrimary = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderNeutral = Color(0xFFE2E8F0);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color surface = Colors.white;
  
  static const Color splashGradientStart = Color(0xFF6366F1);
  static const Color splashGradientEnd = Color(0xFF4F46E5);
  
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warningLight = Color(0xFFFEF3C7);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight);
  static const TextStyle heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight);
  static const TextStyle heading3 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight);
  static const TextStyle heading4 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight);
  static const TextStyle caption = TextStyle(fontSize: 14, color: AppColors.textSecondaryLight);
  static const TextStyle subtitle = TextStyle(fontSize: 16, color: AppColors.textSecondaryLight);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, color: AppColors.textPrimaryLight);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, color: AppColors.textPrimaryLight);
  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.textPrimaryLight);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: AppColors.textSecondaryLight);
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight);
  static const TextStyle labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight);
  static const TextStyle buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(primary: AppColors.primary, secondary: AppColors.secondary, surface: AppColors.surfaceLight, error: AppColors.error),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimaryLight),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryLight),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.surfaceLight, foregroundColor: AppColors.textPrimaryLight, elevation: 0),
      cardTheme: CardThemeData(color: AppColors.surfaceLight, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight))),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight))),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.secondary, surface: AppColors.surfaceDark, error: AppColors.error),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
        titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimaryDark),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondaryDark),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.bgDark, foregroundColor: AppColors.textPrimaryDark, elevation: 0),
      cardTheme: CardThemeData(color: AppColors.surfaceDark, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderDark))),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surfaceDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderDark))),
    );
  }
}
