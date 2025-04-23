import 'package:cloud_firestore/cloud_firestore.dart';

class ContactMessage {
  final String? id;
  final String name;
  final String email;
  final String message;
  final DateTime timestamp;
  final String userId;

  ContactMessage({
    this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  factory ContactMessage.fromMap(String id, Map<String, dynamic> map) {
    return ContactMessage(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }
}
