import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/notification_settings.dart';
import '../models/notification.dart';
import '../models/product.dart';
import '../providers/firestore_provider.dart';
import 'firestore_service.dart';
import '../config/theme.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firestoreService = ref.watch(firestoreProvider);
  return NotificationService(firestoreService);
});

class NotificationService {
  final FirestoreService _firestoreService;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Set<String> _processedNotifications = <String>{};
  Timer? _expiryCheckTimer;
  Timer? _lowStockCheckTimer;
  Timer? _weeklySummaryTimer;
  bool _isInitialized = false;
  bool _hasNewNotifications = false;

  NotificationService(this._firestoreService) 
      : _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _initializeLocalNotifications();
      _startAllChecks();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = response.payload!.split(',');
      if (data.length >= 2) {
        final type = data[0];
        final id = data[1];
        // Use your navigation method here (e.g., GoRouter)
      }
    }
  }

  void _startAllChecks() {
    _stopAllChecks();

    // Initial check with delay
    Future.delayed(const Duration(seconds: 5), () {
      _checkExpiringProducts();
      _checkLowStockProducts();
      _checkWeeklySummary();
    });

    // Set up periodic checks
    _expiryCheckTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _checkExpiringProducts();
    });

    _lowStockCheckTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _checkLowStockProducts();
    });

    _weeklySummaryTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _checkWeeklySummary();
    });
  }

  void _stopAllChecks() {
    _expiryCheckTimer?.cancel();
    _lowStockCheckTimer?.cancel();
    _weeklySummaryTimer?.cancel();
    
    _expiryCheckTimer = null;
    _lowStockCheckTimer = null;
    _weeklySummaryTimer = null;
  }

  Future<void> _checkExpiringProducts() async {
    try {
      final settings = await _firestoreService.getNotificationSettings();
      final notificationSettings = NotificationSettings.fromMap(settings);
      
      if (!notificationSettings.expiryNotifications) return;

      final products = await _firestoreService.getAllProducts();
      final now = DateTime.now();

      for (final product in products) {
        final daysUntilExpiry = product.expiryDate.difference(now).inDays;
        
        if (daysUntilExpiry <= notificationSettings.expiryThresholdDays && daysUntilExpiry > 0) {
          await _createNotification(
            title: 'Product Expiring Soon',
            message: '${product.name} will expire in $daysUntilExpiry days',
            type: NotificationType.expiry,
            productId: product.id,
            areaId: product.areaId,
          );
        }
      }
    } catch (e) {
      print('Error checking expiring products: $e');
    }
  }
  
  // Add method to mark notifications as seen
  Future<void> markNotificationsAsSeen() async {
    _hasNewNotifications = false;
    // Optionally persist this state to Firestore if needed
    try {
      await _firestoreService.markAllNotificationsAsRead();
    } catch (e) {
      print('Error marking notifications as seen: $e');
    }
  }

  Future<void> _checkLowStockProducts() async {
    try {
      final settings = await _firestoreService.getNotificationSettings();
      final notificationSettings = NotificationSettings.fromMap(settings);
      
      if (!notificationSettings.lowStockNotifications) return;

      final products = await _firestoreService.getAllProducts();

      for (final product in products) {
        final threshold = notificationSettings.lowStockThresholds[product.category] ?? 2;
        
        if (product.quantity <= threshold) {
          await _createNotification(
            title: 'Low Stock Alert',
            message: '${product.name} is running low (${product.quantity} ${product.unit} left)',
            type: NotificationType.lowStock,
            productId: product.id,
            areaId: product.areaId,
          );
        }
      }
    } catch (e) {
      print('Error checking low stock products: $e');
    }
  }

  Future<void> _checkWeeklySummary() async {
    try {
      final settings = await _firestoreService.getNotificationSettings();
      final notificationSettings = NotificationSettings.fromMap(settings);
      
      if (!notificationSettings.weeklyReminders) return;

      final now = DateTime.now();
      if (!notificationSettings.weeklyReminderDays.contains(now.weekday)) return;

      final scheduledTime = notificationSettings.reminderTime;
      if (now.hour != scheduledTime.hour || 
          (now.minute - scheduledTime.minute).abs() > 5) return;

      final products = await _firestoreService.getAllProducts();
      final expiringCount = products.where((p) => 
        p.expiryDate.difference(now).inDays <= notificationSettings.expiryThresholdDays
      ).length;
      
      final lowStockCount = products.where((p) {
        final threshold = notificationSettings.lowStockThresholds[p.category] ?? 2;
        return p.quantity <= threshold;
      }).length;

      if (expiringCount > 0 || lowStockCount > 0) {
        await _createNotification(
          title: 'Weekly Inventory Summary',
          message: 'You have $expiringCount products expiring soon and $lowStockCount products running low.',
          type: NotificationType.weeklySummary,
        );
      }
    } catch (e) {
      print('Error generating weekly summary: $e');
    }
  }

  Future<void> _createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? productId,
    String? areaId,
  }) async {
    try {
      if (await _isDuplicateNotification(
        title: title,
        type: type,
        productId: productId,
        areaId: areaId,
      )) {
        return;
      }

      final notification = GroceryNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        productId: productId,
        areaId: areaId,
      );

      await _firestoreService.addNotification(notification);
      await _showLocalNotification(notification);
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Update the addNotification method to set hasNewNotifications
  Future<void> addNotification(GroceryNotification notification) async {
    try {
      await _firestoreService.addNotification(notification);
      _hasNewNotifications = true;
      await _showLocalNotification(notification);
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Future<bool> _isDuplicateNotification({
    required String title,
    required NotificationType type,
    String? productId,
    String? areaId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = '${type.name}_${productId ?? ''}_${areaId ?? ''}_$today';
    
    if (_processedNotifications.contains(key)) {
      return true;
    }
    
    _processedNotifications.add(key);
    return false;
  }

  Future<void> _showLocalNotification(GroceryNotification notification) async {
    try {
      final settings = await _firestoreService.getNotificationSettings();
      final notificationSettings = NotificationSettings.fromMap(settings);
      
      if (!notificationSettings.instantAlerts) return;

      final androidDetails = AndroidNotificationDetails(
        'grocery_notifications',
        'Grocery Notifications',
        channelDescription: 'Notifications for grocery management',
        importance: Importance.high,
        priority: Priority.high,
        color: _getNotificationColor(notification.type),
      );

      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      String? payload;
      if (notification.productId != null) {
        payload = 'product,${notification.productId}';
      } else if (notification.areaId != null) {
        payload = 'area,${notification.areaId}';
      }

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        notification.title,
        notification.message,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.expiry:
        return GroceryColors.warning;
      case NotificationType.lowStock:
        return GroceryColors.error;
      case NotificationType.weeklySummary:
        return GroceryColors.teal;
      case NotificationType.productAdded:
        return GroceryColors.success;
      case NotificationType.productUpdated:
        return GroceryColors.teal;
      case NotificationType.productRemoved:
        return GroceryColors.error;
    }
  }

  Future<void> clearAllNotifications() async {
    await _firestoreService.clearAllNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markNotificationAsRead(notificationId);
  }

  void dispose() {
    _stopAllChecks();
  }
}
