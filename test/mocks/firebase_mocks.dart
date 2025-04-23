import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

// Mock FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final MockUser _mockUser = MockUser();
  @override
  User? get currentUser => _mockUser;
}

// Mock Firestore (only authentication, no Firestore collections)
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
