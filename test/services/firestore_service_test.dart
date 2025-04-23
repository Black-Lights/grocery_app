import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:grocery/services/firestore_service.dart';
import 'package:grocery/models/area.dart';
import '../mocks/firebase_mocks.dart';

void main() {
  late FirestoreService firestoreService;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    fakeFirestore = FakeFirebaseFirestore(); // Use Fake Firestore
    mockAuth = MockFirebaseAuth();
    firestoreService = FirestoreService(firestore: fakeFirestore, auth: mockAuth);
  });

  group('User Profile Operations', () {
    test('createUserProfile should create user document', () async {
      final data = {'email': 'test@example.com', 'createdAt': FieldValue.serverTimestamp()};
      await firestoreService.createUserProfile(userId: 'test-user-id', data: data);
      final doc = await fakeFirestore.collection('users').doc('test-user-id').get();
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('email', 'test@example.com'));
    });
  });

  group('Area Management', () {
    test('addArea should create a new area', () async {
      final areaId = await firestoreService.addArea('Pantry', 'Storage for dry goods');
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('areas').doc(areaId).get();
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('name', 'Pantry'));
    });

    test('updateArea should modify an existing area', () async {
      final areaId = await firestoreService.addArea('Pantry', 'Storage for dry goods');
      final updatedArea = Area(id: areaId, name: 'Updated Pantry', description: 'Updated description', createdAt: DateTime.now(), updatedAt: DateTime.now());
      await firestoreService.updateArea(updatedArea);
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('areas').doc(areaId).get();
      expect(doc.data(), containsPair('name', 'Updated Pantry'));
    });

    test('deleteArea should remove an area', () async {
      final areaId = await firestoreService.addArea('Pantry', 'Storage for dry goods');
      await firestoreService.deleteArea(areaId);
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('areas').doc(areaId).get();
      expect(doc.exists, isFalse);
    });
  });

  group('Product Management', () {
    test('addProduct should create a new product', () async {
      final areaId = await firestoreService.addArea('Pantry', 'Storage for dry goods');
      final productId = await firestoreService.addProduct(
        areaId,
        name: 'Rice',
        category: 'Grains',
        manufacturingDate: DateTime(2024, 1, 1),
        expiryDate: DateTime(2025, 1, 1),
        quantity: 10.0,
        unit: 'kg',
      );
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('areas').doc(areaId).collection('products').doc(productId).get();
      expect(doc.exists, isTrue);
      expect(doc.data(), containsPair('name', 'Rice'));
    });

    test('updateProduct should modify an existing product', () async {
      final areaId = await firestoreService.addArea('Pantry', 'Storage for dry goods');
      final productId = await firestoreService.addProduct(
        areaId,
        name: 'Rice',
        category: 'Grains',
        manufacturingDate: DateTime(2024, 1, 1),
        expiryDate: DateTime(2025, 1, 1),
        quantity: 10.0,
        unit: 'kg',
      );
      await firestoreService.updateProduct(areaId, productId, name: 'Brown Rice');
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('areas').doc(areaId).collection('products').doc(productId).get();
      expect(doc.data(), containsPair('name', 'Brown Rice'));
    });

    test('deleteProduct should remove a product', () async {
      final areaId = await firestoreService.addArea('Pantry', 'Storage for dry goods');
      final productId = await firestoreService.addProduct(
        areaId,
        name: 'Rice',
        category: 'Grains',
        manufacturingDate: DateTime(2024, 1, 1),
        expiryDate: DateTime(2025, 1, 1),
        quantity: 10.0,
        unit: 'kg',
      );
      await firestoreService.deleteProduct(areaId, productId);
      final doc = await fakeFirestore.collection('users').doc('test-user-id').collection('areas').doc(areaId).collection('products').doc(productId).get();
      expect(doc.exists, isFalse);
    });
  });
}
