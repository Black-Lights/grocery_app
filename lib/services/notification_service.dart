import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/notification_settings.dart';
import '../models/notification.dart';
import '../models/product.dart';
import 'firestore_service.dart';
import '../config/theme.dart';

class NotificationService extends GetxService {
  final FirestoreService _firestoreService;
  final RxList<GroceryNotification> notifications = <GroceryNotification>[].obs;
  final Rx<NotificationSettings> settings = NotificationSettings().obs;
  final RxList<GroceryNotification> recentNotifications = <GroceryNotification>[].obs;
  final RxBool hasNewNotifications = false.obs;
  late final FlutterLocalNotificationsPlugin flutterLocalNotifications;

   // Add this to track processed notifications
  final Set<String> _processedNotifications = <String>{};


  Timer? _expiryCheckTimer;
  Timer? _lowStockCheckTimer;
  Timer? _weeklySummaryTimer;
  bool _isInitialized = false;

  // // Getter for recent notifications
  // List<GroceryNotification> get recentNotifications => notifications.toList();

 NotificationService({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService {
    flutterLocalNotifications = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    try {
      final settingsData = await _firestoreService.getNotificationSettings();
      settings.value = NotificationSettings.fromMap(settingsData);

      // Load existing notifications first
      await _loadExistingNotifications();
      
      // Start all checks
      _startAllChecks();
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> refreshNotifications() async {
    try {
      print('Refreshing notifications...');
      final freshNotifications = await _firestoreService.getRecentNotifications();
      notifications.value = freshNotifications;
      print('Notifications refreshed. Count: ${notifications.length}');
    } catch (e) {
      print('Error refreshing notifications: $e');
    }
  }

  Future<void> initializeService() async {
    if (_isInitialized) return;
    
    print('Initializing NotificationService...');
    
    try {
      // Initialize local notifications
      await _initializeNotifications();
      
      // Load settings
      final settingsData = await _firestoreService.getNotificationSettings();
      settings.value = NotificationSettings.fromMap(settingsData);
      
      // Load existing notifications
      await refreshNotifications();
      
      // Start checks
      _startAllChecks();
      
      // Set up periodic refresh
      Timer.periodic(Duration(minutes: 5), (_) {
        refreshNotifications();
      });
      
      _isInitialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }

  // Add method to clear processed notifications
  void _clearProcessedNotifications() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    _processedNotifications.removeWhere((key) => !key.endsWith(today));
  }

  // Override onInit to set up daily cleanup
  @override
  void onInit() {
    super.onInit();
    // Clear processed notifications daily
    Timer.periodic(Duration(hours: 24), (_) {
      _clearProcessedNotifications();
      _startAllChecks();
    });
  }


  @override
  void onClose() {
    _stopAllChecks();
    super.onClose();
  }

  // Modify the check methods to run less frequently
  void _startAllChecks() {
    print('Starting notification checks...');
    
    // Cancel existing timers
    _stopAllChecks();

    // Initial check with delay
    Future.delayed(Duration(seconds: 5), () {
      _checkExpiringProducts();
      _checkLowStockProducts();
      _checkWeeklySummary();
    });

    // Set up periodic checks with longer intervals
    _expiryCheckTimer = Timer.periodic(Duration(hours: 6), (_) {
      print('Running scheduled expiry check');
      _checkExpiringProducts();
    });

    _lowStockCheckTimer = Timer.periodic(Duration(hours: 6), (_) {
      print('Running scheduled low stock check');
      _checkLowStockProducts();
    });

    _weeklySummaryTimer = Timer.periodic(Duration(hours: 1), (_) {
      print('Running scheduled weekly summary check');
      _checkWeeklySummary();
    });

    print('Periodic checks scheduled');
  }

  Future<void> _initializeNotifications() async {
    try {
      print('Initializing local notifications...');
      
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

      await flutterLocalNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions on iOS
      if (GetPlatform.isIOS) {
        await flutterLocalNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
      rethrow;
    }
  }

  Future<void> _loadExistingNotifications() async {
    try {
      print('Loading existing notifications...');
      final existingNotifications = await _firestoreService.getRecentNotifications();
      notifications.value = existingNotifications;
      print('Loaded ${existingNotifications.length} notifications');
    } catch (e) {
      print('Error loading existing notifications: $e');
      rethrow;
    }
  }

  void _stopAllChecks() {
    _expiryCheckTimer?.cancel();
    _lowStockCheckTimer?.cancel();
    _weeklySummaryTimer?.cancel();
    
    _expiryCheckTimer = null;
    _lowStockCheckTimer = null;
    _weeklySummaryTimer = null;
  }

  void _checkLowStockProducts() async {
    try {
      if (!settings.value.lowStockNotifications) return;

      print('Checking for low stock products...');
      final products = await _firestoreService.getAllProducts();

      for (final product in products) {
        final threshold = settings.value.lowStockThresholds[product.category] ?? 2;
        
        if (product.quantity <= threshold) {
          print('Found low stock product: ${product.name}, quantity: ${product.quantity}');
          
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

  void _checkWeeklySummary() async {
    try {
      if (!settings.value.weeklyReminders) return;

      final now = DateTime.now();
      if (!settings.value.weeklyReminderDays.contains(now.weekday)) return;

      // Check if we're within the scheduled time (with 5-minute window)
      final scheduledTime = settings.value.reminderTime;
      if (now.hour != scheduledTime.hour || 
          (now.minute - scheduledTime.minute).abs() > 5) return;

      print('Generating weekly summary...');
      
      final products = await _firestoreService.getAllProducts();
      final expiringCount = products.where((p) => 
        p.expiryDate.difference(now).inDays <= settings.value.expiryThresholdDays
      ).length;
      
      final lowStockCount = products.where((p) {
        final threshold = settings.value.lowStockThresholds[p.category] ?? 2;
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

  // Make sure this method is properly defined
  void _checkExpiringProducts() async {
    try {
      if (!settings.value.expiryNotifications) return;

      print('Checking for expiring products...');
      final products = await _firestoreService.getAllProducts();
      final now = DateTime.now();

      for (final product in products) {
        final daysUntilExpiry = product.expiryDate.difference(now).inDays;
        
        if (daysUntilExpiry <= settings.value.expiryThresholdDays && daysUntilExpiry > 0) {
          print('Found expiring product: ${product.name}, days left: $daysUntilExpiry');
          
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

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = response.payload!.split(',');
      if (data.length >= 2) {
        final type = data[0];
        final id = data[1];
        
        switch (type) {
          case 'product':
            Get.toNamed('/product/$id');
            break;
          case 'area':
            Get.toNamed('/area/$id');
            break;
        }
      }
    }
  }

  // void _listenToNotifications() {
  //   _firestoreService.notificationsStream.listen((notifications) {
  //     this.notifications.value = notifications;
  //   });
  // }

  Future<void> _showLocalNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? productId,
    String? areaId,
  }) async {
    try {
      if (!settings.value.instantAlerts) return;

      final androidDetails = AndroidNotificationDetails(
        'grocery_notifications',
        'Grocery Notifications',
        channelDescription: 'Notifications for grocery management',
        importance: Importance.high,
        priority: Priority.high,
        color: _getNotificationColor(type),
      );

      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      String? payload;
      if (productId != null) {
        payload = 'product,$productId';
      } else if (areaId != null) {
        payload = 'area,$areaId';
      }

      await flutterLocalNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        message,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: payload,
      );

      print('Local notification shown: $title');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Modify the duplicate check method
  Future<bool> _isDuplicateNotification({
    required String title,
    required NotificationType type,
    String? productId,
    String? areaId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = '${type.name}_${productId ?? ''}_${areaId ?? ''}_$today';
    
    if (_processedNotifications.contains(key)) {
      print('Duplicate notification found: $key');
      return true;
    }
    
    _processedNotifications.add(key);
    return false;
  }

  Future<void> _createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? productId,
    String? areaId,
  }) async {
    try {
      // Check for duplicates first
      final isDuplicate = await _isDuplicateNotification(
        title: title,
        type: type,
        productId: productId,
        areaId: areaId,
      );

      if (isDuplicate) {
        print('Skipping duplicate notification: $title');
        return;
      }

      print('Creating new notification: $title');

      final notification = GroceryNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        productId: productId,
        areaId: areaId,
      );

      // Add to Firestore first
      await _firestoreService.addNotification(notification);

      // Update local list
      notifications.insert(0, notification);
      hasNewNotifications.value = true;

      // Show local notification
      await _showLocalNotification(
        title: title,
        message: message,
        type: type,
        productId: productId,
        areaId: areaId,
      );

      print('Notification created and stored. Total notifications: ${notifications.length}');
    } catch (e) {
      print('Error creating notification: $e');
    }
  }


  Future<void> _updateRecentNotifications() async {
    final notifications = await _firestoreService.getRecentNotifications();
    recentNotifications.value = notifications;
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.expiry:
        return GroceryColors.warning;
      case NotificationType.lowStock:
        return GroceryColors.error;
      case NotificationType.weeklySummary:
        return GroceryColors.teal;
      default:
        return GroceryColors.navy;
    }
  }

  Future<void> markNotificationsAsSeen() async {
    hasNewNotifications.value = false;
  }

  Future<void> clearAllNotifications() async {
    try {
      await _firestoreService.clearAllNotifications();
      notifications.clear();
      hasNewNotifications.value = false;
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Get recent notifications for home page
  List<GroceryNotification> getRecentNotificationsForHome() {
    return recentNotifications
        .take(5) // Show only last 5 notifications
        .toList();
  }

  void _startExpiryCheckTimer() {
    Future.delayed(Duration(minutes: 1), () async {
      if (!settings.value.expiryNotifications) return;

      final products = await _firestoreService.getAllProducts();
      final expiringProducts = products.where((product) {
        final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
        return daysUntilExpiry <= settings.value.expiryThresholdDays && daysUntilExpiry > 0;
      }).toList();

      for (final product in expiringProducts) {
        final daysLeft = product.expiryDate.difference(DateTime.now()).inDays;
        await _createNotification(
          title: 'Product Expiring Soon',
          message: '${product.name} will expire in $daysLeft days',
          type: NotificationType.expiry,
          productId: product.id,
          areaId: product.areaId,
        );
      }

      _startExpiryCheckTimer();
    });
  }

  void _startLowStockCheckTimer() {
    Future.delayed(Duration(minutes: 1), () async {
      if (!settings.value.lowStockNotifications) return;

      final products = await _firestoreService.getAllProducts();
      for (final product in products) {
        final threshold = settings.value.lowStockThresholds[product.category] ?? 2;
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

      _startLowStockCheckTimer();
    });
  }

  void _scheduleWeeklySummary() {
    if (!settings.value.weeklyReminders) return;

    Future.delayed(Duration(minutes: 1), () async {
      final now = DateTime.now();
      if (settings.value.weeklyReminderDays.contains(now.weekday)) {
        final products = await _firestoreService.getAllProducts();
        final expiringCount = products.where((p) => 
          p.expiryDate.difference(now).inDays <= settings.value.expiryThresholdDays
        ).length;
        
        final lowStockCount = products.where((p) {
          final threshold = settings.value.lowStockThresholds[p.category] ?? 2;
          return p.quantity <= threshold;
        }).length;

        await _createNotification(
          title: 'Weekly Inventory Summary',
          message: 'You have $expiringCount products expiring soon and $lowStockCount products running low.',
          type: NotificationType.weeklySummary,
        );
      }

      _scheduleWeeklySummary();
    });
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    await _firestoreService.updateNotificationSettings(newSettings.toMap());
    settings.value = newSettings;
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markNotificationAsRead(notificationId);
  }
}
