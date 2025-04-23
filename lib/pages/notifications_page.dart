import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../config/theme.dart';

class NotificationsPage extends StatelessWidget {
  final NotificationService _notificationService = Get.find();
  final FirestoreService _firestoreService = Get.find();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: AppBar(
        backgroundColor: GroceryColors.navy,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: GroceryColors.surface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.cleaning_services_outlined,
              color: GroceryColors.surface,
              size: isTablet ? 28 : 24,
            ),
            onPressed: () => _notificationService.clearAllNotifications(),
            tooltip: 'Clear all notifications',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<GroceryNotification>>(
        stream: _firestoreService.notificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications',
                style: TextStyle(color: GroceryColors.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: isTablet ? 80 : 64,
                    color: GroceryColors.grey300,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: GroceryColors.grey400,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: GroceryColors.grey400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            padding: EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                background: Container(
                  color: GroceryColors.error.withOpacity(0.1),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.delete_outline,
                    color: GroceryColors.error,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _notificationService.clearAllNotifications();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: GroceryColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GroceryColors.grey100),
                  ),
                  child: ListTile(
                    leading: _buildNotificationIcon(notification.type),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: GroceryColors.navy,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: GroceryColors.grey400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 10,
                            color: GroceryColors.grey300,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (notification.productId != null) {
                        Get.toNamed('/product/${notification.productId}');
                      } else if (notification.areaId != null) {
                        Get.toNamed('/area/${notification.areaId}');
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.expiry:
        iconData = Icons.warning_amber_rounded;
        color = GroceryColors.warning;
        break;
      case NotificationType.lowStock:
        iconData = Icons.inventory_2_outlined;
        color = GroceryColors.error;
        break;
      case NotificationType.weeklySummary:
        iconData = Icons.summarize_outlined;
        color = GroceryColors.teal;
        break;
      default:
        iconData = Icons.notifications_outlined;
        color = GroceryColors.navy;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
