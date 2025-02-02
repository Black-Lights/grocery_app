import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/product_image_service.dart';
import '../../../constants/food_categories.dart';
import '../../../pages/product_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Area area;
  final bool isLargeScreen;
  final VoidCallback? onTap;
  final ProductImageService _productImageService = ProductImageService();

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
      elevation: 0,
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
        onTap: () => Get.to(() => ProductPage(
          product: product,
          area: area,
          isTablet: isLargeScreen,
        )),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: isLargeScreen ? 200 : 140,
              decoration: BoxDecoration(
                color: GroceryColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: FutureBuilder<String?>(
                future: product.barcode != null
                    ? _productImageService.getProductImage(product.barcode!, null)
                    : Future.value(null),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Center(
                      child: Image.asset(
                        getCategoryIcon(product.category),
                        width: isLargeScreen ? 80 : 60,
                        height: isLargeScreen ? 80 : 60,
                        color: GroceryColors.grey400,
                      ),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.file(
                      File(snapshot.data!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading cached image: $error');
                        return Center(
                          child: Image.asset(
                            getCategoryIcon(product.category),
                            width: isLargeScreen ? 80 : 60,
                            height: isLargeScreen ? 80 : 60,
                            color: GroceryColors.grey400,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                              fontWeight: FontWeight.bold,
                              color: GroceryColors.navy,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isExpired || isExpiringSoon)
                          Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              isExpired
                                  ? Icons.error_outline
                                  : Icons.warning_amber_rounded,
                              size: isLargeScreen ? 16 : 14,
                              color: isExpired
                                  ? GroceryColors.error
                                  : GroceryColors.warning,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Area and Category
                    Row(
                      children: [
                        Icon(
                          Icons.storage_outlined,
                          size: isLargeScreen ? 14 : 12,
                          color: GroceryColors.teal,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            area.name,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 12 : 10,
                              color: GroceryColors.teal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    Spacer(),

                    // Quantity and Expiry
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
          size: isLargeScreen ? 14 : 12,
          color: color ?? GroceryColors.grey400,
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 12 : 10,
              color: color ?? GroceryColors.grey400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
