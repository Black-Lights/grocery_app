import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_colors.dart';

// Global ProviderContainer for static access
final _container = ProviderContainer();

// Theme providers
final currentThemeProvider = StateProvider<ThemeType>((ref) {
  return ThemeType.default_theme;
});

final _currentPaletteProvider = Provider<ColorPalette>((ref) {
  final currentTheme = ref.watch(currentThemeProvider);
  return ThemeColors.themes[currentTheme]!;
});

class GroceryColors {
  // Static colors that don't change with theme
  static const Color _skyBlue = Color(0xFFC8C9E6);
  static const Color _beige = Color(0xFFF5EFEB);
  static const Color _grey100 = Color(0xFFECEEF1);
  static const Color _grey200 = Color(0xFFDFE3E8);
  static const Color _grey300 = Color(0xFFC4C9D1);
  static const Color _grey400 = Color(0xFF949DA7);
  static const Color _warning = Color(0xFFF5A623);

  // Get current palette
  static ColorPalette get _palette => _container.read(_currentPaletteProvider);

  // Theme-dependent colors
  static Color get navy => _palette.navy;
  static Color get teal => _palette.teal;
  static Color get skyBlue => _skyBlue;
  static Color get beige => _beige;
  static Color get white => Colors.white;
  static Color get background => _palette.background;
  static Color get surface => Colors.white;
  static Color get grey100 => _grey100;
  static Color get grey200 => _grey200;
  static Color get grey300 => _grey300;
  static Color get grey400 => _grey400;
  static Color get success => _palette.success;
  static Color get warning => _warning;
  static Color get error => _palette.error;
}

class GroceryTheme {
  static ThemeData get theme => getThemeData();

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: GroceryColors.white,
    labelStyle: TextStyle(
      color: GroceryColors.grey400,
    ),
    prefixIconColor: GroceryColors.navy,
    suffixIconColor: GroceryColors.grey400,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: GroceryColors.skyBlue),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: GroceryColors.skyBlue.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: GroceryColors.teal, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: GroceryColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: GroceryColors.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static ThemeData getThemeData() {
    return ThemeData(
      primaryColor: GroceryColors.navy,
      scaffoldBackgroundColor: GroceryColors.background,
      colorScheme: ColorScheme.light(
        primary: GroceryColors.navy,
        secondary: GroceryColors.teal,
        error: GroceryColors.error,
        background: GroceryColors.background,
        surface: GroceryColors.surface,
        onPrimary: GroceryColors.white,
        onSecondary: GroceryColors.white,
        onBackground: GroceryColors.navy,
        onSurface: GroceryColors.navy,
      ),
      inputDecorationTheme: inputDecorationTheme,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: GroceryColors.navy,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: GroceryColors.navy,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: GroceryColors.navy,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: GroceryColors.navy,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GroceryColors.navy,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: GroceryColors.navy,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: GroceryColors.navy,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: GroceryColors.grey400,
        ),
      ),
      cardTheme: CardTheme(
        color: GroceryColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: GroceryColors.skyBlue.withOpacity(0.5)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: GroceryColors.navy,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: GroceryColors.white),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GroceryColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GroceryColors.teal,
          foregroundColor: GroceryColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GroceryColors.teal,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: GroceryColors.teal,
        foregroundColor: GroceryColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: GroceryColors.skyBlue.withOpacity(0.5),
        thickness: 1,
        space: 24,
      ),
    );
  }

  // Method to change theme
  static void setTheme(ThemeType themeType) {
    _container.read(currentThemeProvider.notifier).state = themeType;
  }

  // Method to dispose container when app closes
  static void dispose() {
    _container.dispose();
  }
}
