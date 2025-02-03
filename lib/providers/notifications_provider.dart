import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../services/firestore_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Provider for new notifications state
final hasNewNotificationsProvider = StateProvider<bool>((ref) => false);

// Provider for notifications stream
final notificationsStreamProvider = StreamProvider<List<GroceryNotification>>((ref) {
  final firestoreService = ref.watch(firestoreProvider);
  return firestoreService.notificationsStream();
});

// Notification Settings Provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NotificationSettingsNotifier(firestore);
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final FirestoreService _firestoreService;

  NotificationSettingsNotifier(this._firestoreService) : super(NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsData = await _firestoreService.getNotificationSettings();
      state = NotificationSettings.fromMap(settingsData);
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      await _firestoreService.updateNotificationSettings(newSettings.toMap());
      state = newSettings;
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }

  Future<void> toggleExpiryNotifications(bool value) async {
    try {
      final newSettings = state.copyWith(expiryNotifications: value);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error toggling expiry notifications: $e');
    }
  }

  Future<void> toggleLowStockNotifications(bool value) async {
    try {
      final newSettings = state.copyWith(lowStockNotifications: value);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error toggling low stock notifications: $e');
    }
  }

  Future<void> toggleWeeklyReminders(bool value) async {
    try {
      final newSettings = state.copyWith(weeklyReminders: value);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error toggling weekly reminders: $e');
    }
  }

  Future<void> toggleInstantAlerts(bool value) async {
    try {
      final newSettings = state.copyWith(instantAlerts: value);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error toggling instant alerts: $e');
    }
  }

  Future<void> updateExpiryThresholdDays(int days) async {
    try {
      final newSettings = state.copyWith(expiryThresholdDays: days);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error updating expiry threshold days: $e');
    }
  }

  Future<void> updateLowStockThresholds(Map<String, int> thresholds) async {
    try {
      final newSettings = state.copyWith(lowStockThresholds: thresholds);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error updating low stock thresholds: $e');
    }
  }

  Future<void> updateReminderTime(NotificationTime time) async {
    try {
      final newSettings = state.copyWith(reminderTime: time);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error updating reminder time: $e');
    }
  }

  Future<void> updateReminderDays(List<int> days) async {
    try {
      final newSettings = state.copyWith(weeklyReminderDays: days);
      await updateSettings(newSettings);
    } catch (e) {
      print('Error updating reminder days: $e');
    }
  }
}

// Provider for notification actions
final notificationActionsProvider = Provider<NotificationActions>((ref) {
  final firestoreService = ref.watch(firestoreProvider);
  return NotificationActions(firestoreService);
});

class NotificationActions {
  final FirestoreService _firestoreService;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationActions(this._firestoreService) {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
  }

  Future<void> addNotification(GroceryNotification notification) async {
    await _firestoreService.addNotification(notification);
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _firestoreService.markAllNotificationsAsRead();
  }

  Future<void> clearAll() async {
    await _firestoreService.clearAllNotifications();
  }

  Future<void> showLocalNotification(GroceryNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      'grocery_notifications',
      'Grocery Notifications',
      channelDescription: 'Notifications for grocery management',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notification.title,
      notification.message,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: '${notification.type.name},${notification.productId ?? ''},${notification.areaId ?? ''}',
    );
  }
}

// Firestore Provider
final firestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
