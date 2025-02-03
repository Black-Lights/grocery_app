import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/notification.dart';
import '../../providers/notifications_provider.dart';
import '../../config/theme.dart';

class NotificationList extends ConsumerWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    
    return notificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(
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
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class NotificationCard extends ConsumerWidget {
  final GroceryNotification notification;

  const NotificationCard({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _getNotificationIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            color: GroceryColors.navy,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: GroceryColors.grey400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Mark as read when tapped
          ref.read(notificationActionsProvider).markAsRead(notification.id);
          
          // Navigate to the appropriate screen
          if (notification.productId != null) {
            context.push('/product/${notification.productId}');
          } else if (notification.areaId != null) {
            context.push('/area/${notification.areaId}');
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
      case NotificationType.productAdded:
        iconData = Icons.add_circle_outline;
        color = GroceryColors.success;
        break;
      case NotificationType.productUpdated:
        iconData = Icons.edit_outlined;
        color = GroceryColors.teal;
        break;
      case NotificationType.productRemoved:
        iconData = Icons.remove_circle_outline;
        color = GroceryColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
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
