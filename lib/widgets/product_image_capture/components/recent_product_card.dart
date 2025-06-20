import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../pages/product_page.dart';
import '../../../services/cached_image_service.dart';
import '../../../constants/food_categories.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Area area;
  final bool isLargeScreen;
  final VoidCallback? onTap;
  final CachedImageService _cachedImageService = CachedImageService();

  ProductCard({
    Key? key,
    required this.product,
    required this.area,
    required this.isLargeScreen,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 30;
    final isExpired = daysUntilExpiry < 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpired
              ? GroceryColors.error.withOpacity(0.5)
              : isExpiringSoon
                  ? GroceryColors.warning.withOpacity(0.5)
                  : GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () => Get.to(() => ProductPage(product: product, area: area, isTablet: isLargeScreen)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              FutureBuilder<String?>(
                future: product.barcode != null
                    ? _cachedImageService.getCachedProductImage(product.barcode!)
                    : Future.value(null),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(snapshot.data!),
                        width: double.infinity,
                        height: isLargeScreen ? 140 : 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackImage();
                        },
                      ),
                    );
                  }
                  return _buildFallbackImage();
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with name and status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: GroceryColors.navy,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.storage_outlined,
                                      size: isLargeScreen ? 16 : 14,
                                      color: GroceryColors.teal,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        area.name,
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 14 : 12,
                                          color: GroceryColors.teal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isExpired || isExpiringSoon)
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                isExpired
                                    ? Icons.error_outline
                                    : Icons.warning_amber_rounded,
                                size: isLargeScreen ? 18 : 16,
                                color: isExpired
                                    ? GroceryColors.error
                                    : GroceryColors.warning,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Product details
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        label: product.category,
                      ),
                      SizedBox(height: 4),
                      _buildDetailRow(
                        icon: Icons.inventory_2_outlined,
                        label: '${product.quantity} ${product.unit}',
                      ),
                      SizedBox(height: 4),
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Expires: ${DateFormat('MMM dd').format(product.expiryDate)}',
                        color: isExpired
                            ? GroceryColors.error
                            : isExpiringSoon
                                ? GroceryColors.warning
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: GroceryColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Image.asset(
          getCategoryIcon(product.category),
          width: 80,
          height: 80,
          color: GroceryColors.grey400,
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isLargeScreen ? 16 : 14,
          color: color ?? GroceryColors.grey400,
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 14 : 12,
              color: color ?? GroceryColors.grey400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
