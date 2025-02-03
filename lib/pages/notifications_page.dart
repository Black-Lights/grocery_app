import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/notification.dart';
import '../providers/notifications_provider.dart';
import '../config/theme.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final notificationsStream = ref.watch(notificationsStreamProvider);
    final notificationActions = ref.watch(notificationActionsProvider);

    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: AppBar(
        backgroundColor: GroceryColors.navy,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: GroceryColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.cleaning_services_outlined,
              color: GroceryColors.white,
              size: isTablet ? 28 : 24,
            ),
            onPressed: () => notificationActions.clearAll(),
            tooltip: 'Clear all notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsStream.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(isTablet);
          }
          return _buildNotificationsList(
            notifications: notifications,
            isTablet: isTablet,
            ref: ref,
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading notifications',
            style: TextStyle(color: GroceryColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: isTablet ? 80 : 64,
            color: GroceryColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: GroceryColors.grey400,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget _buildNotificationsList({
    required List<GroceryNotification> notifications,
    required bool isTablet,
    required WidgetRef ref,
  }) {
    final notificationActions = ref.read(notificationActionsProvider);

    return ListView.builder(
      itemCount: notifications.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.uniqueKey),
          background: Container(
            color: GroceryColors.error.withOpacity(0.1),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.delete_outline,
              color: GroceryColors.error,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            notificationActions.clearAll();
          },
          child: _NotificationCard(
            notification: notification,
            isTablet: isTablet,
            onTap: () {
              if (notification.productId != null) {
                context.push('/product/${notification.productId}');
              } else if (notification.areaId != null) {
                context.push('/area/${notification.areaId}');
              }
              if (!notification.isRead) {
                notificationActions.markAsRead(notification.id);
              }
            },
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final GroceryNotification notification;
  final bool isTablet;
  final VoidCallback onTap;

  const _NotificationCard({
    Key? key,
    required this.notification,
    required this.isTablet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? GroceryColors.surface 
            : GroceryColors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GroceryColors.grey100),
      ),
      child: ListTile(
        leading: _buildNotificationIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
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
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: GroceryColors.grey300,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationIcon() {
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
