import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grocery/services/notification_service.dart';
import 'package:grocery/services/firestore_service.dart';
import 'package:grocery/models/notification.dart';
import 'package:grocery/models/notification_settings.dart';
import '../mocks/firebase_mocks.dart';

void main() {
  late NotificationService notificationService;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late FirestoreService firestoreService;
  late FlutterLocalNotificationsPlugin mockLocalNotifications;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    firestoreService = FirestoreService(firestore: fakeFirestore, auth: mockAuth);
    mockLocalNotifications = FlutterLocalNotificationsPlugin();
    notificationService = NotificationService(firestoreService: firestoreService);
  });

  group('Notification Service Tests', () {
    test('addNotification should create a new notification', () async {
      final notification = GroceryNotification(
        id: 'notif-1',
        title: 'Test Notification',
        message: 'This is a test',
        type: NotificationType.expiry,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await firestoreService.addNotification(notification);
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('notifications').doc('notif-1').get();
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('title', 'Test Notification'));
    });

    test('getRecentNotifications should retrieve notifications', () async {
      final notification = GroceryNotification(
        id: 'notif-2',
        title: 'Another Notification',
        message: 'Fetching notifications test',
        type: NotificationType.lowStock,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await firestoreService.addNotification(notification);
      final notifications = await firestoreService.getRecentNotifications();
      expect(notifications.length, greaterThan(0));
      expect(notifications.first.title, 'Another Notification');
    });

    test('markNotificationAsRead should update notification status', () async {
      final notification = GroceryNotification(
        id: 'notif-3',
        title: 'Read Test',
        message: 'Mark as read test',
        type: NotificationType.weeklySummary,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await firestoreService.addNotification(notification);
      await firestoreService.markNotificationAsRead('notif-3');
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('notifications').doc('notif-3').get();
      expect(doc.data(), containsPair('isRead', true));
    });

    test('clearAllNotifications should remove all notifications', () async {
      final notification = GroceryNotification(
        id: 'notif-4',
        title: 'Clear Test',
        message: 'Clearing notifications test',
        type: NotificationType.lowStock,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await firestoreService.addNotification(notification);
      await firestoreService.clearAllNotifications();
      final snapshot = await fakeFirestore.collection('users').doc('test-user-id').collection('notifications').get();
      expect(snapshot.docs.isEmpty, isTrue);
    });
  });
}
