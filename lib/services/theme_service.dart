import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum ThemeType {
  classic,
  nature,
  ocean,
  sunset,
  dark
}

class ThemeService extends GetxService {
  final _storage = GetStorage();
  final _key = 'theme';
  final currentTheme = ThemeType.classic.obs;
  
  // Cache the current theme data
  late ThemeData _themeData;

  ThemeService() {
    _themeData = _getThemeDataForType(ThemeType.classic);
  }

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  void loadTheme() {
    try {
      final savedTheme = _storage.read(_key);
      if (savedTheme != null) {
        currentTheme.value = ThemeType.values.firstWhere(
          (e) => e.toString() == savedTheme,
          orElse: () => ThemeType.classic,
        );
        _themeData = _getThemeDataForType(currentTheme.value);
      }
    } catch (e) {
      log('Error loading theme: $e');
    }
  }

  Future<void> saveTheme(ThemeType type) async {
    try {
      await _storage.write(_key, type.toString());
      currentTheme.value = type;
      _themeData = _getThemeDataForType(type);
      Get.forceAppUpdate();
    } catch (e) {
      log('Error saving theme: $e');
    }
  }

  ThemeData getThemeData() => _themeData;

  ThemeData _getThemeDataForType(ThemeType type) {
    switch (type) {
      case ThemeType.classic:
        return _classicTheme;
      case ThemeType.nature:
        return _natureTheme;
      case ThemeType.ocean:
        return _oceanTheme;
      case ThemeType.sunset:
        return _sunsetTheme;
      case ThemeType.dark:
        return _darkTheme;
    }
  }

  static final ThemeData _classicTheme = ThemeData(
    primaryColor: const Color(0xFF2F4156),
    scaffoldBackgroundColor: const Color(0xFFF5EFEB),
    fontFamily: 'Poppins',
    useMaterial3: true,
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2F4156),
      secondary: Color(0xFF567CBD),
      error: Color(0xFFE74C3C),
      background: Color(0xFFF5EFEB),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF2F4156),
      onSurface: Color(0xFF2F4156),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2F4156),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8C9E6)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF567CBD),
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData _natureTheme = ThemeData(
    primaryColor: const Color(0xFF2D5A27),
    scaffoldBackgroundColor: const Color(0xFFF6F8E6),
    fontFamily: 'Poppins',
    useMaterial3: true,
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2D5A27),
      secondary: Color(0xFF4CAF50),
      error: Color(0xFFE57373),
      background: Color(0xFFF6F8E6),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF2D5A27),
      onSurface: Color(0xFF2D5A27),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D5A27),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB8E994)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData _oceanTheme = ThemeData(
    primaryColor: const Color(0xFF1A237E),
    scaffoldBackgroundColor: const Color(0xFFE8EAF6),
    fontFamily: 'Poppins',
    useMaterial3: true,
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A237E),
      secondary: Color(0xFF0097A7),
      error: Color(0xFFEF5350),
      background: Color(0xFFE8EAF6),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF1A237E),
      onSurface: Color(0xFF1A237E),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A237E),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB3E5FC)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF0097A7),
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData _sunsetTheme = ThemeData(
    primaryColor: const Color(0xFF5D4037),
    scaffoldBackgroundColor: const Color(0xFFFBE9E7),
    fontFamily: 'Poppins',
    useMaterial3: true,
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF5D4037),
      secondary: Color(0xFFFF7043),
      error: Color(0xFFEF5350),
      background: Color(0xFFFBE9E7),
      surface: Color(0xFFFFFFFF),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFF5D4037),
      onSurface: Color(0xFF5D4037),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5D4037),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFFCCBC)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFFFF7043),
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    primaryColor: const Color(0xFF212121),
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Poppins',
    useMaterial3: true,
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF424242),
      secondary: Color(0xFF757575),
      error: Color(0xFFCF6679),
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onBackground: Color(0xFFFFFFFF),
      onSurface: Color(0xFFFFFFFF),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFFFFFFFF),
      ),
    ),

    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF424242)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF757575),
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
