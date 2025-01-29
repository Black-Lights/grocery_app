import 'package:flutter/material.dart';

enum ThemeType {
  default_theme,
  nature_theme,
  ocean_theme,
  sunset_theme,
  monochrome_theme,
}

class ThemeColors {
  static final Map<ThemeType, ColorPalette> themes = {
    ThemeType.default_theme: DefaultPalette(),
    ThemeType.nature_theme: NaturePalette(),
    ThemeType.ocean_theme: OceanPalette(),
    ThemeType.sunset_theme: SunsetPalette(),
    ThemeType.monochrome_theme: MonochromePalette(),
  };
}

abstract class ColorPalette {
  Color get navy;
  Color get teal;
  Color get skyBlue;
  Color get beige;
  Color get white;
  Color get background;
  Color get surface;
  Color get grey100;
  Color get grey200;
  Color get grey300;
  Color get grey400;
  Color get success;
  Color get warning;
  Color get error;
  String get name;
}

class DefaultPalette implements ColorPalette {
  @override final Color navy = const Color(0xFF2F4156);
  @override final Color teal = const Color(0xFF567CBD);
  @override final Color skyBlue = const Color(0xFFC8C9E6);
  @override final Color beige = const Color(0xFFF5EFEB);
  @override final Color white = const Color(0xFFFFFFFF);
  @override final Color background = const Color(0xFFF5EFEB);
  @override final Color surface = const Color(0xFFFFFFFF);
  @override final Color grey100 = const Color(0xFFECEEF1);
  @override final Color grey200 = const Color(0xFFDFE3E8);
  @override final Color grey300 = const Color(0xFFC4C9D1);
  @override final Color grey400 = const Color(0xFF949DA7);
  @override final Color success = const Color(0xFF567CBD);
  @override final Color warning = const Color(0xFFF5A623);
  @override final Color error = const Color(0xFFE74C3C);
  @override final String name = "Default Theme";
}

class NaturePalette implements ColorPalette {
  @override final Color navy = const Color(0xFF2D5A27);
  @override final Color teal = const Color(0xFF4CAF50);
  @override final Color skyBlue = const Color(0xFFB8E994);
  @override final Color beige = const Color(0xFFF6F8E6);
  @override final Color white = const Color(0xFFFFFFFF);
  @override final Color background = const Color(0xFFF6F8E6);
  @override final Color surface = const Color(0xFFFFFFFF);
  @override final Color grey100 = const Color(0xFFECF0E6);
  @override final Color grey200 = const Color(0xFFDFE8D9);
  @override final Color grey300 = const Color(0xFFC4D1C2);
  @override final Color grey400 = const Color(0xFF94A792);
  @override final Color success = const Color(0xFF4CAF50);
  @override final Color warning = const Color(0xFFFFB74D);
  @override final Color error = const Color(0xFFE57373);
  @override final String name = "Nature Theme";
}

class OceanPalette implements ColorPalette {
  @override final Color navy = const Color(0xFF1A237E);
  @override final Color teal = const Color(0xFF0097A7);
  @override final Color skyBlue = const Color(0xFFB3E5FC);
  @override final Color beige = const Color(0xFFE8EAF6);
  @override final Color white = const Color(0xFFFFFFFF);
  @override final Color background = const Color(0xFFE8EAF6);
  @override final Color surface = const Color(0xFFFFFFFF);
  @override final Color grey100 = const Color(0xFFECEFF1);
  @override final Color grey200 = const Color(0xFFCFD8DC);
  @override final Color grey300 = const Color(0xFFB0BEC5);
  @override final Color grey400 = const Color(0xFF90A4AE);
  @override final Color success = const Color(0xFF0097A7);
  @override final Color warning = const Color(0xFFFFB74D);
  @override final Color error = const Color(0xFFEF5350);
  @override final String name = "Ocean Theme";
}

class SunsetPalette implements ColorPalette {
  @override final Color navy = const Color(0xFF5D4037);
  @override final Color teal = const Color(0xFFFF7043);
  @override final Color skyBlue = const Color(0xFFFFCCBC);
  @override final Color beige = const Color(0xFFFBE9E7);
  @override final Color white = const Color(0xFFFFFFFF);
  @override final Color background = const Color(0xFFFBE9E7);
  @override final Color surface = const Color(0xFFFFFFFF);
  @override final Color grey100 = const Color(0xFFEFEBE9);
  @override final Color grey200 = const Color(0xFFD7CCC8);
  @override final Color grey300 = const Color(0xFFBCAAA4);
  @override final Color grey400 = const Color(0xFF8D6E63);
  @override final Color success = const Color(0xFFFF7043);
  @override final Color warning = const Color(0xFFFFB74D);
  @override final Color error = const Color(0xFFEF5350);
  @override final String name = "Sunset Theme";
}

class MonochromePalette implements ColorPalette {
  @override final Color navy = const Color(0xFF212121);
  @override final Color teal = const Color(0xFF616161);
  @override final Color skyBlue = const Color(0xFFE0E0E0);
  @override final Color beige = const Color(0xFFF5F5F5);
  @override final Color white = const Color(0xFFFFFFFF);
  @override final Color background = const Color(0xFFF5F5F5);
  @override final Color surface = const Color(0xFFFFFFFF);
  @override final Color grey100 = const Color(0xFFEEEEEE);
  @override final Color grey200 = const Color(0xFFE0E0E0);
  @override final Color grey300 = const Color(0xFFBDBDBD);
  @override final Color grey400 = const Color(0xFF9E9E9E);
  @override final Color success = const Color(0xFF616161);
  @override final Color warning = const Color(0xFF757575);
  @override final Color error = const Color(0xFF424242);
  @override final String name = "Monochrome Theme";
}
