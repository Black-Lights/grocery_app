import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './profile_page.dart';
import './notifications_settings_page.dart';
import './about_page.dart';
import './contact_page.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: isTablet ? 24 : 20),
        ),
      ),
      body: ListView(
        children: [
          // Profile Section
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text('Profile Settings'),
            subtitle: Text('Edit your profile information'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Get.to(() => ProfilePage()),
          ),
          Divider(),

          // Notifications Section
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Manage notification preferences'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Get.to(() => NotificationsSettingsPage()),
          ),
          Divider(),

          // About Section
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Get.to(() => AboutPage()),
          ),
          Divider(),

          // Contact Section
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text('Contact Us'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Get.to(() => ContactPage()),
          ),
          Divider(),

          // App Version
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
