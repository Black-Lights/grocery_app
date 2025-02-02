import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../constants/food_categories.dart';
import '../../../services/shopping_service.dart';
import '../dialogs/add_edit_product_dialog.dart';
import '../dialogs/delete_product_dialog.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Area area;
  final bool isTablet;
  final VoidCallback onAddProduct;

  // Remove const from constructor
  ProductList({
    Key? key,
    required this.products,
    required this.area,
    required this.isTablet,
    required this.onAddProduct,
  }) : super(key: key);

  // Move ShoppingService to a getter
  ShoppingService get _shoppingService => Get.find<ShoppingService>();


  Map<String, List<Product>> _groupProductsByCategory() {
    final grouped = <String, List<Product>>{};
    
    for (final product in products) {
      if (!grouped.containsKey(product.category)) {
        grouped[product.category] = [];
      }
      grouped[product.category]!.add(product);
    }

    // Sort categories alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  Widget _buildCategoryHeader(String category, int itemCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Image.asset(
            getCategoryIcon(category),
            width: 24,
            height: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: GroceryColors.navy,
                  ),
                ),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: GroceryColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddToShoppingList(Product product) async {
    try {
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
    } catch (e) {
      print('Error adding to shopping list: $e');
      Get.snackbar(
        'Error',
        'Failed to add to shopping list',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
      );
    }
  }

  void _handleEdit(Product product) {
    Get.dialog(
      AddEditProductDialog(
        area: area,
        product: product,
        isTablet: isTablet,
      ),
    );
  }

  void _handleDelete(Product product) {
    Get.dialog(
      DeleteProductDialog(
        product: product,
        area: area,
        isTablet: isTablet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: isTablet ? 64 : 48,
              color: GroceryColors.grey300,
            ),
            SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: GroceryColors.grey400,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add products to get started',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: GroceryColors.grey400,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddProduct,
              icon: Icon(Icons.add),
              label: Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GroceryColors.teal,
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final groupedProducts = _groupProductsByCategory();

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: groupedProducts.length,
      itemBuilder: (context, index) {
        final category = groupedProducts.keys.elementAt(index);
        final categoryProducts = groupedProducts[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(category, categoryProducts.length),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categoryProducts.length,
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: ProductCard(
                    product: product,
                    area: area,
                    isTablet: isTablet,
                    onEdit: () => _handleEdit(product),
                    onDelete: () => _handleDelete(product),
                    onAddToShoppingList: () => _handleAddToShoppingList(product),
                  ),
                );
              },
            ),
            if (index < groupedProducts.length - 1)
              Divider(height: 32),
          ],
        );
      },
    );
  }
}
