import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firestore_service.dart';

class NotificationsSettingsPage extends StatefulWidget {
  @override
  _NotificationsSettingsPageState createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  Map<String, bool> _settings = {
    'expiryNotifications': true,
    'lowStockNotifications': true,
    'weeklyReminders': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _firestoreService.getNotificationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load notification settings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      await _firestoreService.updateNotificationSetting(key, value);
      setState(() {
        _settings[key] = value;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update setting',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: isTablet ? 24 : 20),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: Text('Expiry Notifications'),
                  subtitle: Text('Get notified when products are about to expire'),
                  value: _settings['expiryNotifications'] ?? true,
                  onChanged: (value) => _updateSetting('expiryNotifications', value),
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Low Stock Alerts'),
                  subtitle: Text('Get notified when products are running low'),
                  value: _settings['lowStockNotifications'] ?? true,
                  onChanged: (value) => _updateSetting('lowStockNotifications', value),
                ),
                Divider(),
                SwitchListTile(
                  title: Text('Weekly Reminders'),
                  subtitle: Text('Get weekly inventory summaries'),
                  value: _settings['weeklyReminders'] ?? false,
                  onChanged: (value) => _updateSetting('weeklyReminders', value),
                ),
              ],
            ),
    );
  }
}
