import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double quantity;  // Add this
  final String unit;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
     required this.quantity,  // Default value
    this.unit = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory ShoppingItem.fromMap(String id, Map<String, dynamic> map) {
    return ShoppingItem(
      id: id,
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] ?? '',
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? quantity,
    String? unit,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      
    );
  }
}
