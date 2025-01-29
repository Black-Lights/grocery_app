import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings/settings_menu_item.dart';
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
                      icon: Icons.info,
                      title: 'About Us',
                      onTap: () {
                        controller.selectSetting(2, 'About');
                        if (!isTablet) Get.to(() => AboutPage());
                      },
                      isSelected: controller.selectedIndex.value == 2,
                      isTablet: isTablet,
                    ),
                    SettingsMenuItem(
                      icon: Icons.contact_support,
                      title: 'Contact Us',
                      onTap: () {
                        controller.selectSetting(3, 'Contact');
                        if (!isTablet) Get.to(() => ContactPage());
                      },
                      isSelected: controller.selectedIndex.value == 3,
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

  Widget _buildSelectedPage() {
    return Obx(() {
      switch (controller.selectedIndex.value) {
        case 0:
          return ProfilePage();
        case 1:
          return NotificationsSettingsPage();
        case 2:
          return AboutPage();
        case 3:
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
