import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSuggestion {
  final String name;
  final double quantity;
  final String unit;
  final String areaName;
  final DateTime expiryDate;
  final String expiryText;
  final int daysUntilExpiry;

  ProductSuggestion({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.areaName,
    required this.expiryDate,
    required this.expiryText,
    required this.daysUntilExpiry,
  });

  factory ProductSuggestion.fromMap(Map<String, dynamic> map) {
    return ProductSuggestion(
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      areaName: map['areaName'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      expiryText: map['expiryText'] ?? '',
      daysUntilExpiry: map['daysUntilExpiry'] ?? 0,
    );
  }
}
