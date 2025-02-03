import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/notification_settings.dart';
import '../providers/notifications_provider.dart';

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({Key? key}) : super(key: key);

  Widget _buildSettingCard({
    required String title,
    required String description,
    required Widget child,
    required bool isTablet,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: GroceryColors.grey400,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDaySelector(bool isTablet, WidgetRef ref) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final settings = ref.watch(notificationSettingsProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final isSelected = settings.weeklyReminderDays.contains(index + 1);
        return InkWell(
          onTap: () {
            final newDays = List<int>.from(settings.weeklyReminderDays);
            if (isSelected) {
              newDays.remove(index + 1);
            } else {
              newDays.add(index + 1);
            }
            ref.read(notificationSettingsProvider.notifier)
              .updateReminderDays(newDays);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? GroceryColors.teal.withOpacity(0.1) : GroceryColors.grey100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? GroceryColors.teal : GroceryColors.grey200,
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
  }

  Widget _buildTimeSelector(bool isTablet, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    return OutlinedButton.icon(
      onPressed: () async {
        final time = await showTimePicker(
          context: ref.context,
          initialTime: TimeOfDay(
            hour: settings.reminderTime.hour,
            minute: settings.reminderTime.minute,
          ),
        );
        if (time != null) {
          ref.read(notificationSettingsProvider.notifier).updateReminderTime(
            NotificationTime(hour: time.hour, minute: time.minute),
          );
        }
      },
      icon: Icon(Icons.access_time, color: GroceryColors.teal),
      label: Text(
        settings.reminderTime.format(),
        style: TextStyle(
          color: GroceryColors.teal,
          fontSize: isTablet ? 14 : 12,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: GroceryColors.teal),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final settings = ref.watch(notificationSettingsProvider);
    final showAppBar = !isTablet || MediaQuery.of(context).size.width <= 1100;

    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                  color: GroceryColors.white,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingCard(
              title: 'Expiry Notifications',
              description: 'Get notified when products are about to expire',
              isTablet: isTablet,
              child: SwitchListTile(
                value: settings.expiryNotifications,
                onChanged: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                    .toggleExpiryNotifications(value);
                },
                title: const Text('Enable Notifications'),
                activeColor: GroceryColors.teal,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Low Stock Alerts',
              description: 'Get notified when products are running low',
              isTablet: isTablet,
              child: SwitchListTile(
                value: settings.lowStockNotifications,
                onChanged: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                    .toggleLowStockNotifications(value);
                },
                title: const Text('Enable Notifications'),
                activeColor: GroceryColors.teal,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
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
                      ref.read(notificationSettingsProvider.notifier)
                        .toggleWeeklyReminders(value);
                    },
                    title: const Text('Enable Weekly Summary'),
                    activeColor: GroceryColors.teal,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (settings.weeklyReminders) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Send summary on:',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: GroceryColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDaySelector(isTablet, ref),
                    const SizedBox(height: 16),
                    Text(
                      'Send at:',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: GroceryColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTimeSelector(isTablet, ref),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              title: 'Instant Alerts',
              description: 'Show pop-up notifications for important updates',
              isTablet: isTablet,
              child: SwitchListTile(
                value: settings.instantAlerts,
                onChanged: (value) {
                  ref.read(notificationSettingsProvider.notifier)
                    .toggleInstantAlerts(value);
                },
                title: const Text('Show Pop-up Notifications'),
                activeColor: GroceryColors.teal,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
