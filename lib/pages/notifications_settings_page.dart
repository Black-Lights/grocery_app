import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

class NotificationsSettingsPage extends StatelessWidget {
  final NotificationService _notificationService = Get.find<NotificationService>();

  Widget _buildSettingCard({
    required String title,
    required String description,
    required Widget child,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: GroceryColors.grey400,
            ),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDaySelector(bool isTablet) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Obx(() {
      final selectedDays = _notificationService.settings.value.weeklyReminderDays;
      
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(7, (index) {
          final isSelected = selectedDays.contains(index + 1);
          return InkWell(
            onTap: () {
              final newDays = List<int>.from(selectedDays);
              if (isSelected) {
                newDays.remove(index + 1);
              } else {
                newDays.add(index + 1);
              }
              _notificationService.updateSettings(
                _notificationService.settings.value.copyWith(
                  weeklyReminderDays: newDays,
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? GroceryColors.teal.withOpacity(0.1)
                    : GroceryColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? GroceryColors.teal
                      : GroceryColors.grey200,
                ),
              ),
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? GroceryColors.teal : GroceryColors.grey400,
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildTimeSelector(bool isTablet) {
    return Obx(() {
      final currentTime = _notificationService.settings.value.reminderTime;
      return OutlinedButton.icon(
        onPressed: () async {
          final time = await showTimePicker(
            context: Get.context!,
            initialTime: TimeOfDay(
              hour: currentTime.hour,
              minute: currentTime.minute,
            ),
          );
          if (time != null) {
            _notificationService.updateSettings(
              _notificationService.settings.value.copyWith(
                reminderTime: NotificationTime(
                  hour: time.hour,
                  minute: time.minute,
                ),
              ),
            );
          }
        },
        icon: Icon(Icons.access_time),
        label: Text(currentTime.format()),
        style: OutlinedButton.styleFrom(
          foregroundColor: GroceryColors.teal,
          side: BorderSide(color: GroceryColors.teal),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      );
    });
  }

  Widget _buildThresholdSlider({
    required String title,
    required int value,
    required Function(int) onChanged,
    required bool isTablet,
    int min = 1,
    int max = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: GroceryColors.grey400,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: GroceryColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value ${value == 1 ? 'day' : 'days'}',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                  color: GroceryColors.teal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: GroceryColors.teal,
            inactiveTrackColor: GroceryColors.skyBlue.withOpacity(0.2),
            thumbColor: GroceryColors.teal,
            overlayColor: GroceryColors.teal.withOpacity(0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final showAppBar = !isTablet || MediaQuery.of(context).size.width <= 1100;

    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 16),
        child: Obx(() {
          final settings = _notificationService.settings.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingCard(
                title: 'Expiry Notifications',
                description: 'Get notified when products are about to expire',
                isTablet: isTablet,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: settings.expiryNotifications,
                      onChanged: (value) {
                        _notificationService.updateSettings(
                          settings.copyWith(expiryNotifications: value),
                        );
                      },
                      title: Text('Enable Notifications'),
                      activeColor: GroceryColors.teal,
                    ),
                    if (settings.expiryNotifications)
                      _buildThresholdSlider(
                        title: 'Notify me before expiry',
                        value: settings.expiryThresholdDays,
                        onChanged: (value) {
                          _notificationService.updateSettings(
                            settings.copyWith(expiryThresholdDays: value),
                          );
                        },
                        isTablet: isTablet,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              _buildSettingCard(
                title: 'Low Stock Alerts',
                description: 'Get notified when products are running low',
                isTablet: isTablet,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: settings.lowStockNotifications,
                      onChanged: (value) {
                        _notificationService.updateSettings(
                          settings.copyWith(lowStockNotifications: value),
                        );
                      },
                      title: Text('Enable Notifications'),
                      activeColor: GroceryColors.teal,
                    ),
                    if (settings.lowStockNotifications) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Set low stock thresholds by category',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: GroceryColors.grey400,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      ...['Dairy', 'Fruits', 'Vegetables', 'Meat'].map((category) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: GroceryColors.navy,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  decoration: InputDecoration(
                                    suffixText: 'items',
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                    text: (settings.lowStockThresholds[category] ?? 2).toString(),
                                  ),
                                  onChanged: (value) {
                                    final threshold = int.tryParse(value) ?? 2;
                                    final newThresholds = Map<String, int>.from(settings.lowStockThresholds);
                                    newThresholds[category] = threshold;
                                    _notificationService.updateSettings(
                                      settings.copyWith(lowStockThresholds: newThresholds),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16),

              _buildSettingCard(
                title: 'Weekly Summary',
                description: 'Get a weekly summary of your inventory',
                isTablet: isTablet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      value: settings.weeklyReminders,
                      onChanged: (value) {
                        _notificationService.updateSettings(
                          settings.copyWith(weeklyReminders: value),
                        );
                      },
                      title: Text('Enable Weekly Summary'),
                      activeColor: GroceryColors.teal,
                    ),
                    if (settings.weeklyReminders) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send summary on',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: GroceryColors.grey400,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildDaySelector(isTablet),
                            SizedBox(height: 16),
                            Text(
                              'Send at',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: GroceryColors.grey400,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildTimeSelector(isTablet),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16),

              _buildSettingCard(
                title: 'Instant Alerts',
                description: 'Show pop-up notifications for important updates',
                isTablet: isTablet,
                child: SwitchListTile(
                  value: settings.instantAlerts,
                  onChanged: (value) {
                    _notificationService.updateSettings(
                      settings.copyWith(instantAlerts: value),
                    );
                  },
                  title: Text('Show Pop-up Notifications'),
                  activeColor: GroceryColors.teal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
