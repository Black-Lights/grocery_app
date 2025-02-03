import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/area.dart';
import '../services/firestore_service.dart';

final firestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final areasStreamProvider = StreamProvider<List<Area>>((ref) {
  final firestoreService = ref.watch(firestoreProvider);
  return firestoreService.getAreas();
});
