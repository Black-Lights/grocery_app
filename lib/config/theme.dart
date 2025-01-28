import 'package:flutter/material.dart';

class GroceryColors {
  // Primary Colors
  static const Color navy = Color(0xFF1F2041);
  static const Color gold = Color(0xFFFFC857);
  static const Color purple = Color(0xFF4B3F72);
  static const Color teal = Color(0xFF119DA4);
  static const Color blue = Color(0xFF19647E);

  // Neutral Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color grey100 = Color(0xFFE6E8EB);
  static const Color grey200 = Color(0xFFCFD2D7);
  static const Color grey300 = Color(0xFFB0B4BA);
  static const Color grey400 = Color(0xFF909499);
  
  // Semantic Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFB302);
  static const Color error = Color(0xFFE74C3C);
}

class GroceryTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: GroceryColors.navy,
      scaffoldBackgroundColor: GroceryColors.background,
      
      colorScheme: ColorScheme.light(
        primary: GroceryColors.navy,
        secondary: GroceryColors.gold,
        error: GroceryColors.error,
        background: GroceryColors.background,
        surface: GroceryColors.surface,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: GroceryColors.navy,
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: GroceryColors.grey100),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GroceryColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GroceryColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GroceryColors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GroceryColors.error),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GroceryColors.navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GroceryColors.teal,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: GroceryColors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
