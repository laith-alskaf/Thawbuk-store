import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // الألوان الأساسية
  static const Color primary = Color(0xFF8B4513); // بني تقليدي
  static const Color primaryLight = Color(0xFFD2691E);
  static const Color primaryDark = Color(0xFF654321);
  
  static const Color secondary = Color(0xFFDC143C); // أحمر تقليدي
  static const Color secondaryLight = Color(0xFFFFB6C1);
  static const Color secondaryDark = Color(0xFF8B0000);
  
  // الألوان المحايدة
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color transparent = Colors.transparent;
  
  // خلفيات
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // الألوان الأساسية
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      
      // الخطوط
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.black,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkGrey,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.grey,
        ),
      ),
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      
      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.grey,
        ),
      ),
      
      // البطاقات
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // اتجاه النص
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // الألوان الأساسية
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        error: AppColors.error,
      ),
      
      // الخطوط
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.lightGrey,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.grey,
        ),
      ),
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
      
      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.black,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.grey,
        ),
      ),
      
      // البطاقات
      cardTheme: const CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // اتجاه النص
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    );
  }
  
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondary,
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        error: AppColors.error,
      ),
      
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: AppColors.white,
      ),
      
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}