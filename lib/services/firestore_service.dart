import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/area.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID with error handling
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    return user.uid;
  }

  // Get user document reference
  DocumentReference<Map<String, dynamic>> get userDoc {
    final uid = currentUserId;
    return _firestore.collection('users').doc(uid);
  }
  
  // Get areas collection reference
  CollectionReference<Map<String, dynamic>> get areasCollection {
    return userDoc.collection('areas');
  }

  // Default storage areas
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

  // Initialize default areas for new user
  Future<void> initializeDefaultAreas() async {
    try {
      // Ensure user is authenticated
      if (_auth.currentUser == null) {
        throw Exception('User must be authenticated');
      }

      print('Initializing areas for user: ${currentUserId}'); // Debug print
      
      final areasSnapshot = await areasCollection.get();
      
      if (areasSnapshot.docs.isEmpty) {
        print('Creating default areas...'); // Debug print
        
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
        print('Default areas created successfully'); // Debug print
      } else {
        print('Areas already exist'); // Debug print
      }
    } catch (e) {
      print('Error in initializeDefaultAreas: $e'); // Debug print
      throw Exception('Failed to initialize default areas: $e');
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
      print('Error adding area: $e'); // Debug print
      throw Exception('Failed to add area: $e');
    }
  }

  // Get all areas
  Stream<List<Area>> getAreas() {
    try {
      return areasCollection
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
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
      print('Error getting areas: $e'); // Debug print
      throw Exception('Failed to get areas: $e');
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
      print('Error getting area: $e'); // Debug print
      throw Exception('Failed to get area: $e');
    }
  }

  // Update area
  Future<void> updateArea(String areaId, String name, String description) async {
    try {
      await areasCollection.doc(areaId).update({
        'name': name,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating area: $e'); // Debug print
      throw Exception('Failed to update area: $e');
    }
  }

  // Delete area
  Future<void> deleteArea(String areaId) async {
    try {
      // Get all products in the area
      final productsSnapshot = await areasCollection
          .doc(areaId)
          .collection('products')
          .get();
      
      // Create batch for multiple deletes
      final batch = _firestore.batch();
      
      // Add product deletes to batch
      for (var doc in productsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Add area delete to batch
      batch.delete(areasCollection.doc(areaId));
      
      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error deleting area: $e'); // Debug print
      throw Exception('Failed to delete area: $e');
    }
  }

  // Add product to area
  Future<String> addProduct(String areaId, {
    required String name,
    required String category,
    required DateTime manufacturingDate,
    required DateTime expiryDate,
    required double quantity,
    required String unit,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final docRef = await areasCollection
          .doc(areaId)
          .collection('products')
          .add({
        'name': name,
        'category': category,
        'manufacturingDate': Timestamp.fromDate(manufacturingDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'quantity': quantity,
        'unit': unit,
        'notes': notes,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e'); // Debug print
      throw Exception('Failed to add product: $e');
    }
  }

  // Get products for specific area
  Stream<List<Product>> getAreaProducts(String areaId) {
    try {
      return areasCollection
          .doc(areaId)
          .collection('products')
          .orderBy('expiryDate')
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
            imageUrl: data['imageUrl'],
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting products: $e'); // Debug print
      throw Exception('Failed to get products: $e');
    }
  }

  // Update product
  Future<void> updateProduct(String areaId, String productId, {
    String? name,
    String? category,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    double? quantity,
    String? unit,
    String? notes,
    String? imageUrl,
  }) async {
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
      if (imageUrl != null) updates['imageUrl'] = imageUrl;

      await areasCollection
          .doc(areaId)
          .collection('products')
          .doc(productId)
          .update(updates);
    } catch (e) {
      print('Error updating product: $e'); // Debug print
      throw Exception('Failed to update product: $e');
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
      print('Error deleting product: $e'); // Debug print
      throw Exception('Failed to delete product: $e');
    }
  }

  // Search products across all areas
  Future<List<Product>> searchProducts(String query) async {
    try {
      List<Product> results = [];
      
      // Get all areas
      final areasSnapshot = await areasCollection.get();
      
      // Search in each area
      for (var areaDoc in areasSnapshot.docs) {
        final productsSnapshot = await areaDoc
            .reference
            .collection('products')
            .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('name', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
            .get();
        
        results.addAll(
          productsSnapshot.docs.map((doc) {
            final data = doc.data();
            return Product(
              id: doc.id,
              name: data['name'] ?? '',
              category: data['category'] ?? '',
              manufacturingDate: (data['manufacturingDate'] as Timestamp).toDate(),
              expiryDate: (data['expiryDate'] as Timestamp).toDate(),
              quantity: (data['quantity'] as num).toDouble(),
              unit: data['unit'] ?? '',
              areaId: areaDoc.id,
              createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              notes: data['notes'],
              imageUrl: data['imageUrl'],
            );
          }),
        );
      }
      
      return results;
    } catch (e) {
      print('Error searching products: $e'); // Debug print
      throw Exception('Failed to search products: $e');
    }
  }
}
