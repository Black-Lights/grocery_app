import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings/settings_menu_item.dart';
import '../widgets/settings/theme_selector.dart';
import '../services/theme_service.dart';
import './profile_page.dart';
import './notifications_settings_page.dart';
import './about_page.dart';
import './contact_page.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  Widget _buildSettingsList(bool isTablet) {
    return Container(
      width: isTablet ? 300 : double.infinity,
      decoration: BoxDecoration(
        color: GroceryColors.background,
        border: isTablet
            ? Border(
                right: BorderSide(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              )
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: GroceryColors.white,
              border: Border(
                bottom: BorderSide(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: GroceryColors.navy,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w600,
                    color: GroceryColors.navy,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                Obx(() => Column(
                  children: [
                    SettingsMenuItem(
                      icon: Icons.person,
                      title: 'Profile Settings',
                      subtitle: 'Edit your profile information',
                      onTap: () {
                        controller.selectSetting(0, 'Profile');
                        if (!isTablet) Get.to(() => ProfilePage());
                      },
                      isSelected: controller.selectedIndex.value == 0,
                      isTablet: isTablet,
                    ),
                    SettingsMenuItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        controller.selectSetting(1, 'Notifications');
                        if (!isTablet) Get.to(() => NotificationsSettingsPage());
                      },
                      isSelected: controller.selectedIndex.value == 1,
                      isTablet: isTablet,
                    ),
                    SettingsMenuItem(
                      icon: Icons.palette,
                      title: 'Theme',
                      subtitle: 'Customize app appearance',
                      onTap: () {
                        controller.selectSetting(2, 'Theme');
                        if (!isTablet) {
                          _showThemeBottomSheet(Get.context!);
                        }
                      },
                      isSelected: controller.selectedIndex.value == 2,
                      isTablet: isTablet,
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: GroceryColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SettingsMenuItem(
                      icon: Icons.info,
                      title: 'About Us',
                      onTap: () {
                        controller.selectSetting(3, 'About');
                        if (!isTablet) Get.to(() => AboutPage());
                      },
                      isSelected: controller.selectedIndex.value == 3,
                      isTablet: isTablet,
                    ),
                    SettingsMenuItem(
                      icon: Icons.contact_support,
                      title: 'Contact Us',
                      onTap: () {
                        controller.selectSetting(4, 'Contact');
                        if (!isTablet) Get.to(() => ContactPage());
                      },
                      isSelected: controller.selectedIndex.value == 4,
                      isTablet: isTablet,
                    ),
                  ],
                )),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: GroceryColors.grey400,
                      fontSize: isTablet ? 14 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
  final isTablet = MediaQuery.of(context).size.width > 600;
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * (isTablet ? 0.8 : 0.7),
      decoration: BoxDecoration(
        color: GroceryColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar for bottom sheet
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: GroceryColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: GroceryColors.white,
              border: Border(
                bottom: BorderSide(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: GroceryColors.navy,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose Theme',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: GroceryColors.navy,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: GroceryColors.navy,
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Description
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: 12,
            ),
            color: GroceryColors.white,
            child: Text(
              'Choose a theme that suits your style. Changes will be applied immediately.',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: GroceryColors.grey400,
              ),
            ),
          ),
          // Theme options
          Expanded(
            child: Container(
              color: GroceryColors.background,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: isTablet ? 24 : 16,
                ),
                children: [
                  _buildThemeOption(
                    'Classic Theme',
                    'Default light theme with navy and teal colors',
                    ThemeType.classic,
                    isTablet,
                  ),
                  _buildThemeOption(
                    'Nature Theme',
                    'Fresh and natural green color scheme',
                    ThemeType.nature,
                    isTablet,
                  ),
                  _buildThemeOption(
                    'Ocean Theme',
                    'Calming blue colors inspired by the sea',
                    ThemeType.ocean,
                    isTablet,
                  ),
                  _buildThemeOption(
                    'Sunset Theme',
                    'Warm and cozy colors for a comfortable feel',
                    ThemeType.sunset,
                    isTablet,
                  ),
                  _buildThemeOption(
                    'Dark Theme',
                    'Easy on the eyes with dark mode colors',
                    ThemeType.dark,
                    isTablet,
                  ),
                  // Bottom padding for better scrolling
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildThemeOption(
  String title,
  String subtitle,
  ThemeType type,
  bool isTablet,
) {
  final themeService = Get.find<ThemeService>();

  return Obx(() {
    final isSelected = themeService.currentTheme.value == type;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? GroceryColors.teal.withOpacity(0.1) : GroceryColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? GroceryColors.teal
              : GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () => themeService.saveTheme(type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  color: _getThemeColor(type),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? GroceryColors.teal
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? GroceryColors.teal : GroceryColors.navy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: GroceryColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: GroceryColors.teal,
                  size: isTablet ? 28 : 24,
                ),
            ],
          ),
        ),
      ),
    );
  });
}

Color _getThemeColor(ThemeType type) {
  switch (type) {
    case ThemeType.classic:
      return GroceryColors.navy;
    case ThemeType.nature:
      return Color(0xFF2D5A27);
    case ThemeType.ocean:
      return Color(0xFF1A237E);
    case ThemeType.sunset:
      return Color(0xFF5D4037);
    case ThemeType.dark:
      return Color(0xFF212121);
  }
}
  Widget _buildSelectedPage() {
    return Obx(() {
      switch (controller.selectedIndex.value) {
        case 0:
          return ProfilePage();
        case 1:
          return NotificationsSettingsPage();
        case 2:
          return Container(
            color: GroceryColors.white,
            child: ThemeSelector(),
          );
        case 3:
          return AboutPage();
        case 4:
          return ContactPage();
        default:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings,
                  size: 64,
                  color: GroceryColors.grey300,
                ),
                SizedBox(height: 16),
                Text(
                  'Select a setting to view',
                  style: TextStyle(
                    fontSize: 18,
                    color: GroceryColors.grey400,
                  ),
                ),
              ],
            ),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _buildSettingsList(true),
            Expanded(
              child: _buildSelectedPage(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: _buildSettingsList(false),
    );
  }
}
