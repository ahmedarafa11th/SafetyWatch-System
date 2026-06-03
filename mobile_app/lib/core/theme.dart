import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.lightCard,
          onSurface: AppColors.lightTextPrimary,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightCard,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.lightCard,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        dividerColor: AppColors.lightBorder,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.darkCard,
          onSurface: AppColors.darkTextPrimary,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkNavBar,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.darkNavBar,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkNavBar,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        dividerColor: AppColors.darkBorder,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      );
}
