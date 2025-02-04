import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../models/product.dart';
import '../models/area.dart';
import '../services/product_image_service.dart';
import '../services/shopping_service.dart';
import '../widgets/area_detail/components/area_sidebar.dart';
import '../widgets/area_detail/dialogs/add_edit_product_dialog.dart';
import '../widgets/area_detail/dialogs/delete_product_dialog.dart';
import '../constants/food_categories.dart';
import 'area_detail_page.dart';
import 'shopping_list_page.dart';

class ProductPage extends StatelessWidget {
  final Product product;
  final Area area;
  final bool isTablet;
  final ShoppingService _shoppingService = Get.find();
  final ProductImageService _productImageService = ProductImageService();

  ProductPage({
    Key? key,
    required this.product,
    required this.area,
    this.isTablet = false,
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = isTablet ? screenWidth * 0.4 : screenWidth;

    final mainContent = Column(
      children: [
        AppBar(
          backgroundColor: GroceryColors.navy,
          title: Text(
            product.name,
            style: TextStyle(color: GroceryColors.surface),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              onPressed: () => Get.to(() => ShoppingListPage(), preventDuplicates: false),
            ),
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: GroceryColors.teal),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: GroceryColors.error),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  Get.dialog(
                    DeleteProductDialog(
                      product: product,
                      area: area,
                      isTablet: isTablet,
                    ),
                  );
                } else if (value == 'edit') {
                  Get.dialog(
                    AddEditProductDialog(
                      area: area,
                      product: product,
                      isTablet: isTablet,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        Expanded(
          child: isTablet ? _buildTabletLayout(imageSize) : _buildMobileLayout(imageSize),
        ),
      ],
    );

    if (!isTablet) {
      return Scaffold(
        body: mainContent,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          AreaSidebar(
            currentArea: area,
            onAreaSelected: (selectedArea) {
              if (selectedArea.id != area.id) {
                Get.back();
                Get.to(() => AreaDetailPage(area: selectedArea));
              }
            },
            isTablet: true,
          ),
          Expanded(child: mainContent),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(double imageSize) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header at the top
          _buildHeaderInfo(),
          SizedBox(height: 24),
          
          // Image and details side by side
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image section (40%)
                Container(
                  width: imageSize,
                  child: _buildProductImage(imageSize),
                ),
                SizedBox(width: 32),  // Spacing between image and details
                // Right side - Details section (60%)
                Expanded(
                  child: _buildProductDetails(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildMobileLayout(double imageSize) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfo(),
          _buildProductImage(imageSize),
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildProductDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
    final expiryColor = daysUntilExpiry <= 0
        ? GroceryColors.error
        : daysUntilExpiry <= 7
            ? GroceryColors.warning
            : GroceryColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Manufacturing Date',
          product.manufacturingDate.toString().split(' ')[0],
          Icons.calendar_today,
        ),
        SizedBox(height: 20),
        _buildDetailRow(
          'Expiry Date',
          product.expiryDate.toString().split(' ')[0],
          Icons.event,
          color: expiryColor,
        ),
        if (product.brand != null && product.brand!.isNotEmpty) ...[
          SizedBox(height: 20),
          _buildDetailRow(
            'Brand',
            product.brand!,
            Icons.business,
          ),
        ],
        SizedBox(height: 20),
        _buildDetailRow(
          'Quantity',
          '${product.quantity} ${product.unit}',
          Icons.shopping_cart,
        ),
        SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () async {
            await _shoppingService.addItem(
              name: product.name,
              quantity: product.quantity,
              unit: product.unit,
            );
            Get.snackbar(
              'Success',
              'Added to shopping list',
              backgroundColor: GroceryColors.success,
              colorText: GroceryColors.white,
            );
          },
          icon: Icon(Icons.add_shopping_cart),
          label: Text('Add to Shopping List'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GroceryColors.teal,
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GroceryColors.navy,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GroceryColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GroceryColors.skyBlue.withOpacity(0.5),
            ),
          ),
          child: Text(
            product.notes?.isNotEmpty == true 
                ? product.notes!
                : 'No notes available',
            style: TextStyle(
              fontSize: 16,
              color: GroceryColors.grey400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GroceryColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              getCategoryIcon(product.category),
              width: 24,
              height: 24,
            ),
          ),
          SizedBox(width: 12),
          Text(
            product.category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: GroceryColors.navy,
            ),
          ),
          if (!isTablet) ...[
            Spacer(),
            Text(
              area.name,
              style: TextStyle(
                fontSize: 16,
                color: GroceryColors.grey400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductImage(double size) {
  return Container(
    width: size,
    height: size * 0.75,
    decoration: BoxDecoration(
      color: GroceryColors.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: GroceryColors.skyBlue.withOpacity(0.5)),
    ),
    child: FutureBuilder<String?>(
      future: product.barcode != null
        ? _productImageService.getProductImage(product.barcode!, null)
        : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(snapshot.data!),  // ✅ Now loads full-size image from local storage
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackImage(size);
              },
            ),
          );

        }

        return _buildFallbackImage(size);
      },
    ),
  );
}


  Widget _buildFallbackImage(double size) {
    return Center(
      child: Image.asset(
        getCategoryIcon(product.category),
        width: size * 0.5,
        height: size * 0.5,
        color: GroceryColors.grey400,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? GroceryColors.grey400),
        SizedBox(width: 12),
        Expanded(  // Added Expanded
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: GroceryColors.grey400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? GroceryColors.navy,
                ),
                softWrap: true,  // Added softWrap
              ),
            ],
          ),
        ),
      ],
    );
  }
}
