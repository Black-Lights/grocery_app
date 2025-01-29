import 'package:flutter/material.dart';

class GroceryColors {
  // Primary Colors
  static const Color navy = Color(0xFF2F4156);
  static const Color teal = Color(0xFF567CBD);
  static const Color skyBlue = Color(0xFFC8C9E6);
  static const Color beige = Color(0xFFF5EFEB);
  static const Color white = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color background = Color(0xFFF5EFEB); // Using beige as background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFECEEF1);
  static const Color grey200 = Color(0xFFDFE3E8);
  static const Color grey300 = Color(0xFFC4C9D1);
  static const Color grey400 = Color(0xFF949DA7);
  
  // Semantic Colors
  static const Color success = Color(0xFF567CBD); // Using teal for success
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE74C3C);
}

class GroceryTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: GroceryColors.navy,
      scaffoldBackgroundColor: GroceryColors.background,
      fontFamily: 'Poppins',
      
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

      textTheme: const TextTheme(
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
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: GroceryColors.navy,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: GroceryColors.navy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GroceryColors.white,
        ),
        iconTheme: IconThemeData(
          color: GroceryColors.white,
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

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GroceryColors.white,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: GroceryColors.grey400,
        ),
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: GroceryColors.grey300,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GroceryColors.skyBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GroceryColors.skyBlue),
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
          backgroundColor: GroceryColors.teal,
          foregroundColor: GroceryColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
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
}
