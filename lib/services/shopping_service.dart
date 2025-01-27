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

  // Add item to shopping list
  // Future<void> addItem(String name, {required double quantity, String unit = ''}) async {
  //   try {
  //     print('Debug - Adding item: $name with quantity: $quantity ${unit.isNotEmpty ? unit : ''}');
      
  //     final data = {
  //       'name': name,
  //       'isCompleted': false,
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //       'quantity': quantity,
  //       'unit': unit,
  //     };
      
  //     print('Debug - Document data to be added: $data');
      
  //     await shoppingListCollection.add(data);
  //     print('Debug - Item added successfully');
  //   } catch (e) {
  //     print('Error adding shopping item: $e');
  //     throw Exception('Failed to add item to shopping list');
  //   }
  // }

  //  Future<void> addItem({
  //   required String name,
  //   required double quantity,
  //   required String unit,
  // }) async {
  //   try {
  //     print('Adding item to shopping list: $name ($quantity $unit)'); // Debug print
      
  //     await shoppingListCollection.add({
  //       'name': name,
  //       'quantity': quantity,
  //       'unit': unit,
  //       'isCompleted': false,
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
      
  //     print('Item added successfully'); // Debug print
  //   } catch (e) {
  //     print('Error adding item to shopping list: $e'); // Debug print
  //     throw Exception('Failed to add item to shopping list');
  //   }
  // }

  // Single, consistent method for adding items
  Future<void> addItem({
    required String name,
    required double quantity,
    String unit = '',
  }) async {
    try {
      print('Debug - Adding item: $name with quantity: $quantity ${unit.isNotEmpty ? unit : ''}');
      
      final data = {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      print('Debug - Document data to be added: $data');
      
      await shoppingListCollection.add(data);
      print('Debug - Item added successfully');
    } catch (e) {
      print('Error adding shopping item: $e');
      throw Exception('Failed to add item to shopping list');
    }
  }

  // Get shopping list stream
  Stream<List<ShoppingItem>> getShoppingList() {
    try {
      print('Debug - Getting shopping list for user: $currentUserId');
      
      return shoppingListCollection
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          print('Debug - Processing document ${doc.id}: $data');

          // Handle quantity conversion
          final rawQuantity = data['quantity'];
          double quantity;
          
          if (rawQuantity is int) {
            quantity = rawQuantity.toDouble();
          } else if (rawQuantity is double) {
            quantity = rawQuantity;
          } else {
            print('Debug - Invalid quantity type: ${rawQuantity.runtimeType}');
            quantity = 1.0;
          }

          print('Debug - Parsed quantity: $quantity');

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

        print('Debug - Returning ${items.length} items');
        return items;
      });
    } catch (e) {
      print('Error getting shopping list: $e');
      throw Exception('Failed to get shopping list');
    }
  }

  // Toggle item completion status
  Future<void> toggleItem(String itemId, bool isCompleted) async {
    try {
      print('Debug - Toggling item $itemId to $isCompleted');
      
      await shoppingListCollection.doc(itemId).update({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Debug - Item toggled successfully');
    } catch (e) {
      print('Error toggling shopping item: $e');
      throw Exception('Failed to update item');
    }
  }

  // Delete single item
  Future<void> deleteItem(String itemId) async {
    try {
      print('Debug - Deleting item $itemId');
      
      await shoppingListCollection.doc(itemId).delete();
      
      print('Debug - Item deleted successfully');
    } catch (e) {
      print('Error deleting shopping item: $e');
      throw Exception('Failed to delete item');
    }
  }

  // Delete all completed items
  Future<void> deleteCompletedItems() async {
    try {
      print('Debug - Deleting all completed items');
      
      final completedItems = await shoppingListCollection
          .where('isCompleted', isEqualTo: true)
          .get();
      
      print('Debug - Found ${completedItems.docs.length} completed items');

      final batch = _firestore.batch();
      
      for (var doc in completedItems.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Debug - Completed items deleted successfully');
    } catch (e) {
      print('Error deleting completed items: $e');
      throw Exception('Failed to delete completed items');
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String itemId, double quantity) async {
    try {
      print('Debug - Updating quantity for item $itemId to $quantity');
      
      await shoppingListCollection.doc(itemId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Debug - Quantity updated successfully');
    } catch (e) {
      print('Error updating item quantity: $e');
      throw Exception('Failed to update item quantity');
    }
  }

  // Update item unit
  Future<void> updateItemUnit(String itemId, String unit) async {
    try {
      print('Debug - Updating unit for item $itemId to $unit');
      
      await shoppingListCollection.doc(itemId).update({
        'unit': unit,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('Debug - Unit updated successfully');
    } catch (e) {
      print('Error updating item unit: $e');
      throw Exception('Failed to update item unit');
    }
  }

  // Get single item
  Future<ShoppingItem?> getItem(String itemId) async {
    try {
      print('Debug - Getting item $itemId');
      
      final doc = await shoppingListCollection.doc(itemId).get();
      
      if (!doc.exists) {
        print('Debug - Item not found');
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
        print('Debug - Invalid quantity type: ${rawQuantity.runtimeType}');
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
      print('Error getting item: $e');
      throw Exception('Failed to get item');
    }
  }
}
