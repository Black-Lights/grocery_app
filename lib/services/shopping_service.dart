import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_item.dart';

class ShoppingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get shoppingListCollection {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('shopping_list');
  }


  // Single, consistent method for adding items
  Future<void> addItem({
    required String name,
    required double quantity,
    String unit = '',
  }) async {
    try {
      log('Debug - Adding item: $name with quantity: $quantity ${unit.isNotEmpty ? unit : ''}');
      
      final data = {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      log('Debug - Document data to be added: $data');
      
      await shoppingListCollection.add(data);
      log('Debug - Item added successfully');
    } catch (e) {
      log('Error adding shopping item: $e');
      throw Exception('Failed to add item to shopping list');
    }
  }

  // Get shopping list stream
  Stream<List<ShoppingItem>> getShoppingList() {
    try {
      log('Debug - Getting shopping list for user: $currentUserId');
      
      return shoppingListCollection
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          log('Debug - Processing document ${doc.id}: $data');

          // Handle quantity conversion
          final rawQuantity = data['quantity'];
          double quantity;
          
          if (rawQuantity is int) {
            quantity = rawQuantity.toDouble();
          } else if (rawQuantity is double) {
            quantity = rawQuantity;
          } else {
            log('Debug - Invalid quantity type: ${rawQuantity.runtimeType}');
            quantity = 1.0;
          }

          log('Debug - Parsed quantity: $quantity');

          return ShoppingItem(
            id: doc.id,
            name: data['name'] ?? '',
            isCompleted: data['isCompleted'] ?? false,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            quantity: quantity,
            unit: data['unit'] ?? '',
          );
        }).toList();

        // Sort items: incomplete first, then by creation date (newest first)
        items.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });

        log('Debug - Returning ${items.length} items');
        return items;
      });
    } catch (e) {
      log('Error getting shopping list: $e');
      throw Exception('Failed to get shopping list');
    }
  }

  // Toggle item completion status
  Future<void> toggleItem(String itemId, bool isCompleted) async {
    try {
      log('Debug - Toggling item $itemId to $isCompleted');
      
      await shoppingListCollection.doc(itemId).update({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      log('Debug - Item toggled successfully');
    } catch (e) {
      log('Error toggling shopping item: $e');
      throw Exception('Failed to update item');
    }
  }

  // Delete single item
  Future<void> deleteItem(String itemId) async {
    try {
      log('Debug - Deleting item $itemId');
      
      await shoppingListCollection.doc(itemId).delete();
      
      log('Debug - Item deleted successfully');
    } catch (e) {
      log('Error deleting shopping item: $e');
      throw Exception('Failed to delete item');
    }
  }

  // Delete all completed items
  Future<void> deleteCompletedItems() async {
    try {
      log('Debug - Deleting all completed items');
      
      final completedItems = await shoppingListCollection
          .where('isCompleted', isEqualTo: true)
          .get();
      
      log('Debug - Found ${completedItems.docs.length} completed items');

      final batch = _firestore.batch();
      
      for (var doc in completedItems.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      log('Debug - Completed items deleted successfully');
    } catch (e) {
      log('Error deleting completed items: $e');
      throw Exception('Failed to delete completed items');
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String itemId, double quantity) async {
    try {
      log('Debug - Updating quantity for item $itemId to $quantity');
      
      await shoppingListCollection.doc(itemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      log('Debug - Quantity updated successfully');
    } catch (e) {
      log('Error updating item quantity: $e');
      throw Exception('Failed to update item quantity');
    }
  }

  // Update item unit
  Future<void> updateItemUnit(String itemId, String unit) async {
    try {
      log('Debug - Updating unit for item $itemId to $unit');
      
      await shoppingListCollection.doc(itemId).update({
        'unit': unit,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      log('Debug - Unit updated successfully');
    } catch (e) {
      log('Error updating item unit: $e');
      throw Exception('Failed to update item unit');
    }
  }

  // Get single item
  Future<ShoppingItem?> getItem(String itemId) async {
    try {
      log('Debug - Getting item $itemId');
      
      final doc = await shoppingListCollection.doc(itemId).get();
      
      if (!doc.exists) {
        log('Debug - Item not found');
        return null;
      }

      final data = doc.data()!;
      
      // Handle quantity conversion
      final rawQuantity = data['quantity'];
      double quantity;
      
      if (rawQuantity is int) {
        quantity = rawQuantity.toDouble();
      } else if (rawQuantity is double) {
        quantity = rawQuantity;
      } else {
        log('Debug - Invalid quantity type: ${rawQuantity.runtimeType}');
        quantity = 1.0;
      }

      return ShoppingItem(
        id: doc.id,
        name: data['name'] ?? '',
        isCompleted: data['isCompleted'] ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        quantity: quantity,
        unit: data['unit'] ?? '',
      );
    } catch (e) {
      log('Error getting item: $e');
      throw Exception('Failed to get item');
    }
  }
}
