import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';

class DeleteProductDialog extends StatelessWidget {
  final Product product;
  final Area area;
  final bool isTablet;
  final FirestoreService _firestoreService = FirestoreService();

  DeleteProductDialog({
    Key? key,
    required this.product,
    required this.area,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isTablet ? 400 : double.infinity,
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: GroceryColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GroceryColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: GroceryColors.error,
                      size: isTablet ? 28 : 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Product',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.w600,
                            color: GroceryColors.error,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'This action cannot be undone',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: GroceryColors.error.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete this product?',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: GroceryColors.navy,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Product Details
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GroceryColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GroceryColors.skyBlue.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'Name',
                          value: product.name,
                        ),
                        SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: product.category,
                        ),
                        SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Quantity',
                          value: '${product.quantity} ${product.unit}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: GroceryColors.background,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: GroceryColors.grey400,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _firestoreService.deleteProduct(area.id, product.id);
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Product deleted successfully',
                          backgroundColor: GroceryColors.success,
                          colorText: GroceryColors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      } catch (e) {
                        Get.back();
                        Get.snackbar(
                          'Error',
                          'Failed to delete product',
                          backgroundColor: GroceryColors.error,
                          colorText: GroceryColors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_outline),
                    label: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GroceryColors.error,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                ],
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
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GroceryColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: isTablet ? 20 : 18,
            color: GroceryColors.navy,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: GroceryColors.grey400,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: GroceryColors.navy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
