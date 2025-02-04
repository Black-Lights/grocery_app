import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/models/area.dart';
import 'package:grocery/models/contact_message.dart';
import 'package:grocery/models/notification.dart';
import 'package:grocery/models/notification_settings.dart';
import 'package:grocery/models/product.dart';
import 'package:grocery/models/product_suggestion.dart';
import 'package:grocery/models/shopping_item.dart';

void main() {
  group('Area Model', () {
    test('Area should convert to and from Map', () {
      final area = Area(
        id: '1',
        name: 'Kitchen',
        description: 'Storage area for kitchen items',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = area.toMap();
      final fromMap = Area.fromMap(area.id, map);

      expect(fromMap.name, equals(area.name));
      expect(fromMap.description, equals(area.description));
    });
  });

  group('ContactMessage Model', () {
    test('ContactMessage should convert to and from Map', () {
      final message = ContactMessage(
        id: 'msg1',
        name: 'John Doe',
        email: 'john@example.com',
        message: 'Hello!',
        timestamp: DateTime.now(),
        userId: 'user123',
      );

      final map = message.toMap();
      final fromMap = ContactMessage.fromMap(message.id!, map);

      expect(fromMap.name, equals(message.name));
      expect(fromMap.email, equals(message.email));
    });
  });

  group('GroceryNotification Model', () {
    test('GroceryNotification should convert to and from Map', () {
      final notification = GroceryNotification(
        id: 'notif1',
        title: 'Stock Alert',
        message: 'Low stock for Milk',
        type: NotificationType.lowStock,
        timestamp: DateTime.now(),
      );

      final map = notification.toMap();
      final fromMap = GroceryNotification.fromMap(map);

      expect(fromMap.title, equals(notification.title));
      expect(fromMap.message, equals(notification.message));
    });
  });

  group('NotificationSettings Model', () {
    test('NotificationSettings should convert to and from Map', () {
      final settings = NotificationSettings(
        expiryNotifications: true,
        lowStockNotifications: true,
        weeklyReminders: false,
        expiryThresholdDays: 7,
      );

      final map = settings.toMap();
      final fromMap = NotificationSettings.fromMap(map);

      expect(fromMap.expiryNotifications, equals(settings.expiryNotifications));
      expect(fromMap.lowStockNotifications, equals(settings.lowStockNotifications));
    });
  });

  group('Product Model', () {
    test('Product should convert to and from Map', () {
      final product = Product(
        id: 'prod1',
        name: 'Apple',
        category: 'Fruits',
        manufacturingDate: DateTime.now().subtract(Duration(days: 10)),
        expiryDate: DateTime.now().add(Duration(days: 20)),
        quantity: 5.0,
        unit: 'kg',
        areaId: 'area1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = product.toMap();
      final fromMap = Product.fromMap(product.id, map);

      expect(fromMap.name, equals(product.name));
      expect(fromMap.category, equals(product.category));
    });
  });

  group('ProductSuggestion Model', () {
    test('ProductSuggestion should convert from Map', () {
      final map = {
        'name': 'Yogurt',
        'quantity': 2.0,
        'unit': 'liters',
        'areaName': 'Fridge',
        'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'expiryText': 'Expiring soon',
        'daysUntilExpiry': 7,
      };

      final suggestion = ProductSuggestion.fromMap(map);

      expect(suggestion.name, equals('Yogurt'));
      expect(suggestion.unit, equals('liters'));
    });
  });

  group('ShoppingItem Model', () {
    test('ShoppingItem should convert to and from Map', () {
      final item = ShoppingItem(
        id: 'shop1',
        name: 'Bread',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        quantity: 1.0,
        unit: 'pack',
      );

      final map = item.toMap();
      final fromMap = ShoppingItem.fromMap(item.id, map);

      expect(fromMap.name, equals(item.name));
      expect(fromMap.isCompleted, equals(item.isCompleted));
    });
  });
}
