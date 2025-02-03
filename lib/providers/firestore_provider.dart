import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';

final firestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
