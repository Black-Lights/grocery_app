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
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'manufacturingDate': Timestamp.fromDate(manufacturingDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
