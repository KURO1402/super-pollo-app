import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.brandRed,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.brandOrange,
          onPrimaryContainer: AppColors.white,
          secondary: AppColors.brandGold,
          onSecondary: AppColors.grey900,
          secondaryContainer: Color(0xFFFFF3E0),
          onSecondaryContainer: AppColors.grey900,
          surface: AppColors.offWhite,
          onSurface: AppColors.grey900,
          surfaceContainerHighest: AppColors.grey100,
          error: AppColors.error,
          onError: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.offWhite,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.brandRed,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.brandRed.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Botón principal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandRed,
            foregroundColor: AppColors.white,
            elevation: 3,
            shadowColor: AppColors.brandRed.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandRed,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.brandRed, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: const TextStyle(color: AppColors.grey500),
          hintStyle: const TextStyle(color: AppColors.grey300),
          prefixIconColor: AppColors.brandRed,
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.brandRed,
          unselectedItemColor: AppColors.grey500,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),

        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.brandRed,
          foregroundColor: AppColors.white,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.grey100,
          selectedColor: AppColors.brandRed.withOpacity(0.15),
          labelStyle: const TextStyle(color: AppColors.grey700),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.grey100,
          thickness: 1,
        ),

        // Íconos
        iconTheme: const IconThemeData(color: AppColors.brandRed),

        // Tipografía base
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: AppColors.grey900, fontWeight: FontWeight.w800),
          titleLarge: TextStyle(
              color: AppColors.grey900, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(
              color: AppColors.grey900, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.grey700),
          bodyMedium: TextStyle(color: AppColors.grey700),
          bodySmall: TextStyle(color: AppColors.grey500),
          labelLarge: TextStyle(
              color: AppColors.white, fontWeight: FontWeight.w700),
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.grey900,
          contentTextStyle: const TextStyle(color: AppColors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ── Tema Oscuro ──────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brandOrange,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.brandRedDim,
          onPrimaryContainer: AppColors.white,
          secondary: AppColors.brandGold,
          onSecondary: AppColors.grey900,
          secondaryContainer: Color(0xFF3E2000),
          onSecondaryContainer: AppColors.brandGold,
          surface: AppColors.navyCard,
          onSurface: AppColors.offWhite,
          surfaceContainerHighest: AppColors.navyLight,
          error: Color(0xFFEF9A9A),
          onError: AppColors.grey900,
        ),
        scaffoldBackgroundColor: AppColors.navyDeep,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navyCard,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: AppColors.navyCard,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Botón principal
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandOrange,
            foregroundColor: AppColors.white,
            elevation: 3,
            shadowColor: AppColors.brandOrange.withOpacity(0.35),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Botón de texto
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandOrange,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.navyLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.navyLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: AppColors.navyLight.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.brandOrange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
          ),
          labelStyle: const TextStyle(color: AppColors.grey300),
          hintStyle: const TextStyle(color: AppColors.grey500),
          prefixIconColor: AppColors.brandOrange,
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navyCard,
          selectedItemColor: AppColors.brandOrange,
          unselectedItemColor: AppColors.grey500,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),

        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.brandOrange,
          foregroundColor: AppColors.white,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.navyLight,
          selectedColor: AppColors.brandOrange.withOpacity(0.2),
          labelStyle: const TextStyle(color: AppColors.offWhite),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.navyLight,
          thickness: 1,
        ),

        // Íconos
        iconTheme: const IconThemeData(color: AppColors.brandOrange),

        // Tipografía base
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: AppColors.offWhite, fontWeight: FontWeight.w800),
          titleLarge: TextStyle(
              color: AppColors.offWhite, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(
              color: AppColors.offWhite, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.grey100),
          bodyMedium: TextStyle(color: AppColors.grey100),
          bodySmall: TextStyle(color: AppColors.grey300),
          labelLarge: TextStyle(
              color: AppColors.white, fontWeight: FontWeight.w700),
        ),

        // SnackBar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.navyLight,
          contentTextStyle: const TextStyle(color: AppColors.offWhite),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}