import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final double quantity;
  final String unit;
  final String areaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.quantity,
    required this.unit,
    required this.areaId,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'manufacturingDate': Timestamp.fromDate(manufacturingDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'quantity': quantity,
      'unit': unit,
      'areaId': areaId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      manufacturingDate: (map['manufacturingDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] ?? '',
      areaId: map['areaId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      notes: map['notes'],
      imageUrl: map['imageUrl'],
    );
  }
}
