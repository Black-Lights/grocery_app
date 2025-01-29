import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../services/notification_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/notification.dart';
import '../../product_image_capture/product_image_capture.dart';

class HomeBanners extends StatelessWidget {
  final NotificationService _notificationService = Get.find();
  final FirestoreService _firestoreService = Get.find();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildNotificationBanner(context, isSmallScreen),
          ),
          Expanded(
            child: _buildScanBanner(context, isSmallScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(BuildContext context, bool isSmallScreen) {
    return StreamBuilder<List<GroceryNotification>>(
      stream: _firestoreService.notificationsStream(),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: GroceryColors.grey100),
            ),
            color: GroceryColors.navy.withOpacity(0.05),
            child: InkWell(
              onTap: () => _showNotificationsList(context, notifications),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: isSmallScreen
                    ? _buildSmallNotificationView(notifications)
                    : _buildLargeNotificationView(notifications),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallNotificationView(List<GroceryNotification> notifications) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GroceryColors.navy.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: GroceryColors.navy,
            size: 24,
          ),
        ),
        if (notifications.isNotEmpty && _notificationService.hasNewNotifications.value)
          Positioned(
            right: 0,
            top: 0,
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
    );
  }

  Widget _buildLargeNotificationView(List<GroceryNotification> notifications) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GroceryColors.navy.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: GroceryColors.navy,
                size: 24,
              ),
            ),
            if (notifications.isNotEmpty && _notificationService.hasNewNotifications.value)
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
        SizedBox(width: 12),
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
          color: GroceryColors.navy,
        ),
      ],
    );
  }

  Widget _buildScanBanner(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: GroceryColors.grey100),
        ),
        color: GroceryColors.teal.withOpacity(0.05),
        child: InkWell(
          onTap: () => Get.to(() => ProductImageCapture()),
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
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: GroceryColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.document_scanner_outlined,
        color: GroceryColors.teal,
        size: 24,
      ),
    );
  }

  Widget _buildLargeScanView() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
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
        SizedBox(width: 12),
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

  void _showNotificationsList(BuildContext context, List<GroceryNotification> notifications) {
    _notificationService.markNotificationsAsSeen();
    final isTablet = MediaQuery.of(context).size.width > 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: GroceryColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GroceryColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: GroceryColors.navy.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
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
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: GroceryColors.navy,
                  ),
                ],
              ),
            ),
            if (notifications.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: isTablet ? 64 : 48,
                        color: GroceryColors.grey300,
                      ),
                      SizedBox(height: 16),
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
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      background: Container(
                        color: GroceryColors.error,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete_outline,
                          color: GroceryColors.surface,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _notificationService.clearAllNotifications();
                      },
                      child: _buildNotificationItem(context, notification),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, GroceryNotification notification) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            SizedBox(height: 4),
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
            Get.toNamed('/product/${notification.productId}');
          } else if (notification.areaId != null) {
            Get.toNamed('/area/${notification.areaId}');
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
