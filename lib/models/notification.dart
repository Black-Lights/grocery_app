enum NotificationType {
  expiry,
  lowStock,
  weeklySummary,
  productAdded,
  productUpdated,
  productRemoved,
}

class GroceryNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final String? productId;
  final String? areaId;
  final bool isRead;
  final String uniqueKey; // Added uniqueKey field

  GroceryNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.productId,
    this.areaId,
    this.isRead = false,
  }) : uniqueKey = _generateUniqueKey(type, productId, areaId, timestamp);

  static String _generateUniqueKey(
    NotificationType type,
    String? productId,
    String? areaId,
    DateTime timestamp,
  ) {
    final date = timestamp.toIso8601String().split('T')[0]; // Get just the date part
    return '${type.name}_${productId ?? ''}_${areaId ?? ''}_$date';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'productId': productId,
      'areaId': areaId,
      'isRead': isRead,
      'uniqueKey': uniqueKey,
    };
  }

  factory GroceryNotification.fromMap(Map<String, dynamic> map) {
    final notification = GroceryNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      timestamp: DateTime.parse(map['timestamp']),
      productId: map['productId'],
      areaId: map['areaId'],
      isRead: map['isRead'] ?? false,
    );
    return notification;
  }

  GroceryNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    String? productId,
    String? areaId,
    bool? isRead,
  }) {
    return GroceryNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      productId: productId ?? this.productId,
      areaId: areaId ?? this.areaId,
      isRead: isRead ?? this.isRead,
    );
  }
}
