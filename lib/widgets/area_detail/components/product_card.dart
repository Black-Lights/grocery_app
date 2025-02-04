import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/product_image_service.dart';
import '../../../constants/food_categories.dart';
import '../../../pages/product_page.dart';
import '../dialogs/add_edit_product_dialog.dart';
import '../dialogs/delete_product_dialog.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Area area;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddToShoppingList;
  final bool isTablet;
  final ProductImageService _productImageService = ProductImageService();

  ProductCard({
    Key? key,
    required this.product,
    required this.area, 
    required this.onEdit,
    required this.onDelete,
    required this.onAddToShoppingList,
    required this.isTablet,
  }) : super(key: key);

  String _getExpiryText(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    if (daysUntilExpiry > 0) {
      return '$daysUntilExpiry days';
    } else if (daysUntilExpiry == 0) {
      return 'Today';
    } else {
      return 'Expired';
    }
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return GroceryColors.error;
    } else if (daysUntilExpiry < 7) {
      return GroceryColors.warning;
    } else {
      return GroceryColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiryText = _getExpiryText(product.expiryDate);
    final expiryColor = _getExpiryColor(product.expiryDate);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: GroceryColors.skyBlue.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => Get.to(() => ProductPage(
          product: product,
          area: area,  // Pass the area
          isTablet: isTablet,
        )),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image or Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: GroceryColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder<String?>(
                  future: product.barcode != null
                      ? _productImageService.getProductImage(product.barcode!, null)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(snapshot.data!),  //   Now loads from local storage if available
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.broken_image_outlined, size: 40, color: GroceryColors.grey400),
                            );
                          },
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.all(12),
                      child: Image.asset(getCategoryIcon(product.category), fit: BoxFit.contain),
                    );
                  },
                ),

              ),
              SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Row(
                  children: [
                    // Name and Expiry
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: GroceryColors.navy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: expiryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              expiryText,
                              style: TextStyle(
                                fontSize: 12,
                                color: expiryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GroceryColors.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.quantity} ${product.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: GroceryColors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // Quick Actions
                    IconButton(
                      icon: Icon(
                        Icons.add_shopping_cart_outlined,
                        color: GroceryColors.teal,
                        size: 20,
                      ),
                      onPressed: onAddToShoppingList,
                      tooltip: 'Add to Shopping List',
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: GroceryColors.grey400,
                        size: 20,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: GroceryColors.teal),
                            title: Text('Edit'),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: GroceryColors.error),
                            title: Text('Delete'),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Get.dialog(
                            AddEditProductDialog(
                              area: area,
                              product: product,
                              isTablet: isTablet,
                            ),
                          );
                        } else if (value == 'delete') {
                          Get.dialog(
                            DeleteProductDialog(
                              product: product,
                              area: area,
                              isTablet: isTablet,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
