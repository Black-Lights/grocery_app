import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../models/notification.dart';
import '../../../providers/notifications_provider.dart';
import '../../product_image_capture/product_image_capture.dart';

class HomeBanners extends ConsumerWidget {
  const HomeBanners({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context, WidgetRef ref) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 600;
      final hasNewNotifications = ref.watch(hasNewNotificationsProvider);
      final notificationsAsync = ref.watch(notificationsStreamProvider);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildNotificationBanner(
                context, 
                isSmallScreen, 
                hasNewNotifications,
                notificationsAsync.value ?? [],
                ref,
              ),
            ),
            Expanded(
              child: _buildScanBanner(context, isSmallScreen),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNotificationBanner(
    BuildContext context, 
    bool isSmallScreen, 
    bool hasNew,
    List<GroceryNotification> notifications,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: GroceryColors.grey100),
        ),
        color: GroceryColors.teal.withOpacity(0.05),
        child: InkWell(
          onTap: () => _showNotificationsList(context, notifications, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: isSmallScreen
                ? _buildSmallNotificationView(context, hasNew, notifications)
                : _buildLargeNotificationView(context, hasNew, notifications),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallNotificationView(
    BuildContext context,
    bool hasNew,
    List<GroceryNotification> notifications,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: GroceryColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: GroceryColors.teal,
              size: 24,
            ),
            if (notifications.isNotEmpty && hasNew)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: GroceryColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GroceryColors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeNotificationView(
    BuildContext context,
    bool hasNew,
    List<GroceryNotification> notifications,
  ) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GroceryColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: GroceryColors.teal,
                size: 24,
              ),
            ),
            if (notifications.isNotEmpty && hasNew)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: GroceryColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GroceryColors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GroceryColors.navy,
                ),
              ),
              Text(
                '${notifications.length} notification${notifications.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: GroceryColors.grey400,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: GroceryColors.teal,
        ),
      ],
    );
  }

  Widget _buildScanBanner(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: GroceryColors.grey100),
        ),
        color: GroceryColors.teal.withOpacity(0.05),
        child: InkWell(
          onTap: () => context.push('/product-image-capture'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: isSmallScreen
                ? _buildSmallScanView()
                : _buildLargeScanView(),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallScanView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: GroceryColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.document_scanner_outlined,
          color: GroceryColors.teal,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLargeScanView() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GroceryColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.document_scanner_outlined,
            color: GroceryColors.teal,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GroceryColors.navy,
                ),
              ),
              Text(
                'Scan to add items',
                style: TextStyle(
                  fontSize: 14,
                  color: GroceryColors.grey400,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: GroceryColors.teal,
        ),
      ],
    );
  }

  void _showNotificationsList(
    BuildContext context, 
    List<GroceryNotification> notifications,
    WidgetRef ref,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    // Mark notifications as seen
    ref.read(hasNewNotificationsProvider.notifier).state = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: GroceryColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildNotificationHeader(context),
            if (notifications.isEmpty)
              _buildEmptyNotificationState(context)
            else
              _buildNotificationsList(context, notifications, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GroceryColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              color: GroceryColors.navy,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: GroceryColors.navy,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotificationState(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: isTablet ? 64 : 48,
              color: GroceryColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<GroceryNotification> notifications,
    WidgetRef ref,
  ) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Expanded(
      child: ListView.builder(
        itemCount: notifications.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.id),
            background: Container(
              color: GroceryColors.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.delete_outline,
                color: GroceryColors.surface,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              ref.read(notificationActionsProvider).clearAll();
            },
            child: _buildNotificationItem(context, notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, GroceryNotification notification) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: GroceryColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GroceryColors.grey100),
      ),
      child: ListTile(
        leading: _getNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            color: GroceryColors.navy,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(
                color: GroceryColors.grey300,
                fontSize: isTablet ? 12 : 10,
              ),
            ),
          ],
        ),
        onTap: () {
          if (notification.productId != null) {
            context.push('/product/${notification.productId}');
          } else if (notification.areaId != null) {
            context.push('/area/${notification.areaId}');
          }
        },
      ),
    );
  }

  Widget _getNotificationIcon(NotificationType type) {
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

