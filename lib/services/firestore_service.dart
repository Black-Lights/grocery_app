import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery/models/contact_message.dart';
import '../models/area.dart';
import '../models/product.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Updated constructor to allow dependency injection
  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get areasCollection {
  if (currentUserId.isEmpty) throw Exception("User ID is null or empty");
  return _firestore.collection('users').doc(currentUserId).collection('areas');
}

  Future<void> createUserProfile({required String userId, required Map<String, dynamic> data}) async {
    try {
      data['acceptedTerms'] = true; // Ensure terms acceptance is stored
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }


   // Add this property for default areas
  final List<Map<String, String>> defaultAreas = [
    {
      'name': 'Refrigerator',
      'description': 'Store items that need refrigeration'
    },
    {
      'name': 'Freezer',
      'description': 'Store frozen items'
    },
    {
      'name': 'Pantry',
      'description': 'Store dry and non-perishable items'
    },
    {
      'name': 'Cabinet',
      'description': 'Store spices and cooking ingredients'
    },
    {
      'name': 'Counter',
      'description': 'Store fruits and vegetables'
    }
  ];

    // Add this method
  Future<void> initializeDefaultAreas() async {
    try {
      
      final areasSnapshot = await areasCollection.get();
      
      if (areasSnapshot.docs.isEmpty) {
        
        // Create batch for multiple writes
        final batch = _firestore.batch();
        
        // Add each default area to batch
        for (var area in defaultAreas) {
          final newAreaRef = areasCollection.doc();
          batch.set(newAreaRef, {
            'name': area['name'],
            'description': area['description'],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Commit the batch
        await batch.commit();
      } else {
        log('Areas already exist, skipping initialization'); // Debug print
      }
    } catch (e) {
      log('Error initializing default areas: $e'); // Debug print
      throw Exception('Failed to initialize default areas: $e');
    }
  }

  // Get user document reference
  DocumentReference<Map<String, dynamic>> get userDoc {
    return _firestore.collection('users').doc(currentUserId);
  }

  // Get user data
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final doc = await userDoc.get();
      if (!doc.exists || doc.data() == null) {
        throw Exception("User data not found");
      }
      return doc.data()!;
    } catch (e) {
      throw Exception("Failed to retrieve user data: $e");
    }
  }


  // Update user profile
  bool isValidUsername(String username) {
    return RegExp(r"^[a-zA-Z0-9_.-]{3,20}$").hasMatch(username);
  }

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    try {
      if (!isValidUsername(username)) {
        throw Exception("Invalid username format");
      }

      if (await isUsernameExists(username)) {
        throw Exception('Username already exists');
      }

      await userDoc.update({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating user profile: $e');
      throw Exception('Failed to update profile');
    }
  }

    // Check if username exists
    Future<bool> isUsernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check username availability');
    }
  }

  // Get single area
  Future<Area?> getArea(String areaId) async {
    try {
      final doc = await areasCollection.doc(areaId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Area(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      log('Error getting area: $e');
      return null;
    }
  }

  // Search products across all areas
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.trim().length < 2) return [];

      log('Searching products for query: $query');
      final queryLower = query.toLowerCase().trim();
      final areas = await areasCollection.get();
      List<Product> results = [];

      for (var area in areas.docs) {
        final areaName = area.data()['name'] ?? '';
        log('Searching in area: $areaName'); // Debug print

        final products = await area.reference
            .collection('products')
            .orderBy('name')
            .get();

        for (var doc in products.docs) {
          final data = doc.data();
          final productName = (data['name'] as String?)?.toLowerCase() ?? '';
          
          // Check if product name contains the search query
          if (productName.contains(queryLower)) {
            log('Found matching product: ${data['name']}'); // Debug print
            
            try {
              final product = Product(
                id: doc.id,
                name: data['name'] ?? '',
                category: data['category'] ?? '',
                manufacturingDate: (data['manufacturingDate'] as Timestamp).toDate(),
                expiryDate: (data['expiryDate'] as Timestamp).toDate(),
                quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
                unit: data['unit'] ?? '',
                areaId: area.id,
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                notes: data['notes'],
              );
              results.add(product);
            } catch (e) {
              log('Error parsing product: $e'); // Debug print
              log('Product data: $data'); // Debug print
            }
          }
        }
      }

      log('Found ${results.length} matching products'); // Debug print
      
      // Sort results by name
      results.sort((a, b) => a.name.compareTo(b.name));
      return results;
    } catch (e) {
      log('Error searching products: $e');
      return [];
    }
  }

  // Get contact messages collection reference
  CollectionReference<Map<String, dynamic>> get contactMessagesCollection {
    return _firestore.collection('contactMessages');
  }

  // Add contact message
  Future<void> addContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      log('Adding contact message from: $name'); // Debug print
      
      await contactMessagesCollection.add({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      });
      
      log('Contact message added successfully'); // Debug print
    } catch (e) {
      log('Error adding contact message: $e'); // Debug print
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // Get user's contact messages
  Stream<List<ContactMessage>> getUserContactMessages() {
    try {
      return contactMessagesCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ContactMessage.fromMap(doc.id, doc.data());
        }).toList();
      });
    } catch (e) {
      log('Error getting contact messages: $e');
      throw Exception('Failed to get contact messages');
    }
  }

  // Get notifications collection reference
  CollectionReference<Map<String, dynamic>> get _notificationsRef {
    if (currentUserId.isEmpty) throw Exception("User ID is null or empty");
    return _firestore.collection('users').doc(currentUserId).collection('notifications');
  }

  Future<List<GroceryNotification>> getRecentNotifications() async {
    try {
      final snapshot = await _notificationsRef
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return GroceryNotification.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();

      return notifications;
    } catch (e) {
      log('Error getting recent notifications: $e');
      return [];
    }
  }

  // Get notification settings (updated version)
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final doc = await userDoc.get();
      if (!doc.exists) {
        return NotificationSettings().toMap();
      }
      final data = doc.data()?['notificationSettings'];
      return data ?? NotificationSettings().toMap();
    } catch (e) {
      log('Error getting notification settings: $e');
      throw Exception('Failed to get notification settings');
    }
  }

  // Update notification settings (updated version)
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await userDoc.set({
        'notificationSettings': settings,
      }, SetOptions(merge: true));
    } catch (e) {
      log('Error updating notification settings: $e');
      throw Exception('Failed to update notification settings');
    }
  }

  Future<void> addNotification(GroceryNotification notification) async {
    try {
      await _notificationsRef
          .doc(notification.id)
          .set(notification.toMap());
      log('Successfully added notification to Firestore');
    } catch (e) {
      log('Error adding notification to Firestore: $e');
      throw e;
    }
  }

// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      log('Clearing all notifications...');
      final batch = _firestore.batch();
      final snapshots = await _notificationsRef.get();
      
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      log('Successfully cleared all notifications');
    } catch (e) {
      log('Error clearing notifications: $e');
      throw e;
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      log('Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read');
    }
  }

  

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      final AggregateQuerySnapshot snapshot = await _notificationsRef
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      log('Error getting unread notifications count: $e');
      throw Exception('Failed to get unread notifications count');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final batch = _firestore.batch();
      final unreadNotifications = await _notificationsRef
          .where('isRead', isEqualTo: false)
          .get();
      
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
    } catch (e) {
      log('Error marking all notifications as read: $e');
      throw Exception('Failed to mark all notifications as read');
    }
  }

  Future<void> deleteOldNotifications() async {
    try {
      // Keep only last 100 notifications
      final allNotifications = await _notificationsRef
          .orderBy('timestamp', descending: true)
          .get();

      if (allNotifications.docs.length > 100) {
        final batch = _firestore.batch();
        for (var i = 100; i < allNotifications.docs.length; i++) {
          batch.delete(allNotifications.docs[i].reference);
        }
        await batch.commit();
      }
    } catch (e) {
      log('Error cleaning old notifications: $e');
    }
  }

  Stream<List<GroceryNotification>> notificationsStream() {
    return _notificationsRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GroceryNotification.fromMap({
              'id': doc.id,
              ...doc.data(),
            });
          }).toList();
        });
  }


// Get all products across all areas
  Future<List<Product>> getAllProducts() async {
    try {
      final areas = await areasCollection.get();
      List<Product> allProducts = [];

      for (var area in areas.docs) {
        final productsSnapshot = await area.reference
            .collection('products')
            .get();

        final products = productsSnapshot.docs.map((doc) {
          final data = doc.data();
          return Product(
            id: doc.id,
            name: data['name'] ?? '',
            category: data['category'] ?? '',
            manufacturingDate: (data['manufacturingDate'] as Timestamp).toDate(),
            expiryDate: (data['expiryDate'] as Timestamp).toDate(),
            quantity: (data['quantity'] as num).toDouble(),
            unit: data['unit'] ?? '',
            areaId: area.id,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            notes: data['notes'],
            brand: data['brand'],    // Added brand field
            barcode: data['barcode'], // Added barcode field
          );
        }).toList();

        allProducts.addAll(products);
      }

      return allProducts;
    } catch (e) {
      log('Error getting all products: $e');
      throw Exception('Failed to get all products');
    }
  }
  


  // Add new area
  Future<String> addArea(String name, String description) async {
    try {
      final docRef = await areasCollection.add({
        'name': name,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception("Failed to add area: $e");
    }
  }

  // Get all areas
  Stream<List<Area>> getAreas() {
    try {
      return areasCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Area(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      });
    } catch (e) {
      log('Error getting areas: $e');
      throw Exception('Failed to get areas');
    }
  }

  // Get products for specific area
  Stream<List<Product>> getAreaProducts(String areaId) {
    try {
      return areasCollection
          .doc(areaId)
          .collection('products')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Product(
            id: doc.id,
            name: data['name'] ?? '',
            category: data['category'] ?? '',
            manufacturingDate: (data['manufacturingDate'] as Timestamp).toDate(),
            expiryDate: (data['expiryDate'] as Timestamp).toDate(),
            quantity: (data['quantity'] as num).toDouble(),
            unit: data['unit'] ?? '',
            areaId: areaId,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            notes: data['notes'],
            brand: data['brand'],    // Added brand field
            barcode: data['barcode'], // Added barcode field
          );
        }).toList();
      });
    } catch (e) {
      log('Error getting products: $e');
      throw Exception('Failed to get products');
    }
  }

  Stream<List<Product>> getRecentProducts(String? areaId) {
    try {
      var query = areaId != null
          ? areasCollection
              .doc(areaId)
              .collection('products')
              .orderBy('createdAt', descending: true)
              .limit(20)
          : _firestore
              .collectionGroup('products')
              .orderBy('createdAt', descending: true)
              .limit(20);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final areaId = doc.reference.parent.parent!.id;
          return Product(
            id: doc.id,
            name: data['name'] ?? '',
            category: data['category'] ?? '',
            manufacturingDate: (data['manufacturingDate'] as Timestamp).toDate(),
            expiryDate: (data['expiryDate'] as Timestamp).toDate(),
            quantity: (data['quantity'] as num).toDouble(),
            unit: data['unit'] ?? '',
            areaId: areaId,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            notes: data['notes'],
            brand: data['brand'],    // Added brand field
            barcode: data['barcode'], // Added barcode field
          );
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get recent products');
    }
  }

  // Add product to area
  Future<String> addProduct(
    String areaId,
    {required String name,
    required String category,
    required DateTime manufacturingDate,
    required DateTime expiryDate,
    required double quantity,
    required String unit,
    String? notes,
    String? brand,
    String? barcode}) async {

    try {
      final docRef = await areasCollection.doc(areaId).collection('products').add({
        'name': name,
        'category': category,
        'manufacturingDate': Timestamp.fromDate(manufacturingDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'quantity': quantity,
        'unit': unit,
        'notes': notes ?? '',
        'brand': brand ?? '',
        'barcode': barcode ?? '',  //   Added barcode field
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception("Failed to add product: $e");
    }
  }

  // Update product
  Future<void> updateProduct(
    String areaId,
    String productId,
    {String? name,
    String? category,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    String? notes,
    String? brand,
    String? barcode}) async {

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (category != null) updates['category'] = category;
      if (manufacturingDate != null) updates['manufacturingDate'] = Timestamp.fromDate(manufacturingDate);
      if (expiryDate != null) updates['expiryDate'] = Timestamp.fromDate(expiryDate);
      if (quantity != null) updates['quantity'] = quantity;
      if (unit != null) updates['unit'] = unit;
      if (notes != null) updates['notes'] = notes;
      if (brand != null) updates['brand'] = brand;
      if (barcode != null) updates['barcode'] = barcode;  //   Added barcode field

      await areasCollection.doc(areaId).collection('products').doc(productId).update(updates);
    } catch (e) {
      throw Exception("Failed to update product: $e");
    }
  }

  // Delete product
  Future<void> deleteProduct(String areaId, String productId) async {
    try {
      await areasCollection
          .doc(areaId)
          .collection('products')
          .doc(productId)
          .delete();
    } catch (e) {
      log('Error deleting product: $e');
      throw Exception('Failed to delete product');
    }
  }

  // Update area
  Future<void> updateArea(Area area) async {
    try {
      await areasCollection.doc(area.id).update({
        'name': area.name,
        'description': area.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating area: $e');
      throw Exception('Failed to update area');
    }
  }

  // Delete area
  Future<void> deleteArea(String areaId) async {
    try {
      final productsSnapshot = await areasCollection
          .doc(areaId)
          .collection('products')
          .get();

      final batch = _firestore.batch();
      for (var doc in productsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(areasCollection.doc(areaId));
      
      await batch.commit();
    } catch (e) {
      log('Error deleting area: $e');
      throw Exception('Failed to delete area');
    }
  }
}
