import 'package:get/get.dart';
import '../services/theme_service.dart';

class SettingsController extends GetxController {
  final RxInt selectedIndex = (-1).obs;
  final RxString selectedTitle = ''.obs;
  late final ThemeService themeService;

  @override
  void onInit() {
    super.onInit();
    themeService = Get.find<ThemeService>();
  }

  void selectSetting(int index, String title) {
    selectedIndex.value = index;
    selectedTitle.value = title;
  }

  void clearSelection() {
    selectedIndex.value = -1;
    selectedTitle.value = '';
  }

  // Add these helper methods for theme management
  void changeTheme(ThemeType theme) {
    themeService.saveTheme(theme);
  }

  ThemeType get currentTheme => themeService.currentTheme.value;

  // Helper method to get the name of the current theme
  String get currentThemeName {
    switch (currentTheme) {
      case ThemeType.classic:
        return 'Classic';
      case ThemeType.nature:
        return 'Nature';
      case ThemeType.ocean:
        return 'Ocean';
      case ThemeType.sunset:
        return 'Sunset';
      case ThemeType.dark:
        return 'Dark';
    }
  }
}
