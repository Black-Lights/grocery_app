import '../models/product.dart';

class ProductStats {
  final int totalProducts;
  final int expiringSoon;
  final int expired;

  ProductStats({
    required this.totalProducts,
    required this.expiringSoon,
    required this.expired,
  });

  static ProductStats calculate(List<Product> products) {
    final now = DateTime.now();
    int expiringSoon = 0;
    int expired = 0;

    for (final product in products) {
      final daysUntilExpiry = product.expiryDate.difference(now).inDays;
      
      if (daysUntilExpiry < 0) {
        expired++;
      } else if (daysUntilExpiry <= 7) {
        expiringSoon++;
      }
    }

    return ProductStats(
      totalProducts: products.length,
      expiringSoon: expiringSoon,
      expired: expired,
    );
  }
}
