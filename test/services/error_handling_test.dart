import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:grocery/services/firestore_service.dart';
import '../mocks/firebase_mocks.dart';

void main() {
  late FirestoreService firestoreService;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    firestoreService = FirestoreService(firestore: fakeFirestore, auth: mockAuth);
  });

  group('Error Handling Tests', () {
    test('createUserProfile should throw exception on Firestore error', () async {
      expect(
        () => firestoreService.createUserProfile(userId: '', data: {'email': 'test@example.com'}),
        throwsA(isA<Exception>()),
      );
    });

    test('getUserData should throw exception when document does not exist', () async {
      expect(() => firestoreService.getUserData(), throwsA(isA<Exception>()));
    });

    test('addArea should throw exception when Firestore fails', () async {
      expect(() => firestoreService.addArea('', 'Storage for dry goods'), throwsA(isA<Exception>()));
    });

    test('addProduct should throw exception if area does not exist', () async {
      expect(
        () => firestoreService.addProduct(
          'non-existent-area',
          name: 'Rice',
          category: 'Grains',
          manufacturingDate: DateTime(2024, 1, 1),
          expiryDate: DateTime(2025, 1, 1),
          quantity: 10.0,
          unit: 'kg',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
