import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../config/theme.dart';

class NotificationList extends StatelessWidget {
  final NotificationService _notificationService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notifications = _notificationService.recentNotifications;
      
      if (notifications.isEmpty) {
        return Center(
          child: Text('No notifications'),
        );
      }

      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(notification: notification);
        },
      );
    });
  }
}

class NotificationCard extends StatelessWidget {
  final GroceryNotification notification;

  const NotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _getNotificationIcon(),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          _formatTimestamp(notification.timestamp),
          style: TextStyle(
            color: GroceryColors.grey400,
            fontSize: 12,
          ),
        ),
        onTap: () {
          if (notification.productId != null) {
            Get.toNamed('/product/${notification.productId}');
          } else if (notification.areaId != null) {
            Get.toNamed('/area/${notification.areaId}');
          }
        },
      ),
    );
  }

  Widget _getNotificationIcon() {
    IconData iconData;
    Color color;

    switch (notification.type) {
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

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
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
