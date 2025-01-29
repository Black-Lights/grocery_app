import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/product_utils.dart';
import '../../../controllers/product_list_controller.dart';
import 'product_card.dart';
import 'empty_product_list.dart';
import '../dialogs/add_edit_product_dialog.dart';
import '../dialogs/delete_product_dialog.dart';
import '../dialogs/add_to_shopping_dialog.dart';

class ProductList extends StatelessWidget {
  final Area area;
  final bool isTablet;
  final VoidCallback onAddProduct;
  final FirestoreService _firestoreService = FirestoreService();
  final ProductListController _controller = Get.put(ProductListController());

  ProductList({
    Key? key,
    required this.area,
    required this.isTablet,
    required this.onAddProduct,
  }) : super(key: key);

  List<Product> _sortProducts(List<Product> products, String sortBy) {
    switch (sortBy) {
      case 'Category (A-Z)':
        return List.from(products)..sort((a, b) => a.category.compareTo(b.category));
      case 'Category (Z-A)':
        return List.from(products)..sort((a, b) => b.category.compareTo(a.category));
      case 'Expiry Date':
        return List.from(products)..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      case 'Name (A-Z)':
        return List.from(products)..sort((a, b) => a.name.compareTo(b.name));
      case 'Name (Z-A)':
        return List.from(products)..sort((a, b) => b.name.compareTo(a.name));
      default:
        return products;
    }
  }

  void _showEditDialog(BuildContext context, Product product) {
    Get.dialog(
      AddEditProductDialog(
        area: area,
        product: product,
        isTablet: isTablet,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    Get.dialog(
      DeleteProductDialog(
        product: product,
        area: area,
        isTablet: isTablet,
      ),
    );
  }

  void _showAddToShoppingDialog(BuildContext context, Product product) {
    Get.dialog(
      AddToShoppingDialog(
        product: product,
        isTablet: isTablet,
      ),
    );
  }

  Widget _buildSortAndStats(List<Product> products) {
    final stats = ProductStats.calculate(products);
    final sorts = ['Category (A-Z)', 'Category (Z-A)', 'Expiry Date', 'Name (A-Z)', 'Name (Z-A)'];

    if (isTablet) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GroceryColors.white,
          border: Border(
            bottom: BorderSide(
              color: GroceryColors.skyBlue.withOpacity(0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            // Sort Button
            Obx(() => PopupMenuButton<String>(
              initialValue: _controller.currentSort.value,
              onSelected: _controller.updateSort,
              itemBuilder: (context) => sorts.map((sort) {
                return PopupMenuItem<String>(
                  value: sort,
                  child: Row(
                    children: [
                      Icon(
                        sort == _controller.currentSort.value 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                        color: sort == _controller.currentSort.value 
                            ? GroceryColors.teal 
                            : GroceryColors.grey400,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(sort),
                    ],
                  ),
                );
              }).toList(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: GroceryColors.skyBlue.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by: ${_controller.currentSort.value}'),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            )),
            SizedBox(width: 24),

            // Stats
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total',
                    value: stats.totalProducts.toString(),
                  ),
                  _buildStat(
                    icon: Icons.warning_amber_outlined,
                    label: 'Expiring Soon',
                    value: stats.expiringSoon.toString(),
                    color: stats.expiringSoon > 0 ? GroceryColors.warning : null,
                  ),
                  _buildStat(
                    icon: Icons.event_busy_outlined,
                    label: 'Expired',
                    value: stats.expired.toString(),
                    color: stats.expired > 0 ? GroceryColors.error : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile version
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: GroceryColors.white,
          border: Border(
            bottom: BorderSide(
              color: GroceryColors.skyBlue.withOpacity(0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            // Sort Button
            Obx(() => PopupMenuButton<String>(
              initialValue: _controller.currentSort.value,
              onSelected: _controller.updateSort,
              itemBuilder: (context) => sorts.map((sort) {
                return PopupMenuItem<String>(
                  value: sort,
                  child: Row(
                    children: [
                      Icon(
                        sort == _controller.currentSort.value 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                        color: sort == _controller.currentSort.value 
                            ? GroceryColors.teal 
                            : GroceryColors.grey400,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(sort),
                    ],
                  ),
                );
              }).toList(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: GroceryColors.skyBlue.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 20),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            )),
            SizedBox(width: 12),

            // Compact Stats
            if (stats.expiringSoon > 0)
              _buildCompactStat(
                icon: Icons.warning_amber_outlined,
                value: stats.expiringSoon.toString(),
                color: GroceryColors.warning,
              ),
            if (stats.expired > 0)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: _buildCompactStat(
                  icon: Icons.event_busy_outlined,
                  value: stats.expired.toString(),
                  color: GroceryColors.error,
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildCategoryHeader(String category, int count) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: GroceryColors.skyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.category_outlined,
            color: GroceryColors.teal,
            size: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: GroceryColors.navy,
                ),
              ),
              Text(
                '$count items',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: GroceryColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? GroceryColors.grey400),
            SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color ?? GroceryColors.navy,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: GroceryColors.grey400,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _firestoreService.getAreaProducts(area.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(context);  // Pass context here
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return EmptyProductList(
            area: area,
            onAddProduct: onAddProduct,
            isTablet: isTablet,
          );
        }

        return Column(
          children: [
            // Sort and Stats Bar
            _buildSortAndStats(products),

            // Products List
            Expanded(
              child: Obx(() {
                final sortedProducts = _sortProducts(
                  products, 
                  _controller.currentSort.value
                );
                final groupedProducts = _groupProductsByCategory(sortedProducts);

                return ListView.builder(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  itemCount: groupedProducts.length,
                  itemBuilder: (context, index) {
                    final category = groupedProducts.keys.elementAt(index);
                    final categoryProducts = groupedProducts[category]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index > 0) SizedBox(height: 24),
                        _buildCategoryHeader(category, categoryProducts.length),
                        SizedBox(height: 16),
                        ...categoryProducts.map((product) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProductCard(
                            product: product,
                            isTablet: isTablet,
                            onEdit: () => _showEditDialog(context, product),
                            onDelete: () => _showDeleteDialog(context, product),
                            onAddToShoppingList: () => _showAddToShoppingDialog(context, product),
                          ),
                        )).toList(),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }
  

  Map<String, List<Product>> _groupProductsByCategory(List<Product> products) {
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

  Widget _buildFilterSection(int totalProducts) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        border: Border(
          bottom: BorderSide(
            color: GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Total Count
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: GroceryColors.skyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: GroceryColors.skyBlue.withOpacity(0.2),
              ),
            ),
            child: Text(
              '$totalProducts Products',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GroceryColors.teal,
              ),
            ),
          ),
          SizedBox(width: 24),

          // Sort Dropdown
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: GroceryColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: GroceryColors.skyBlue.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 20,
                  color: GroceryColors.navy,
                ),
                SizedBox(width: 8),
                Text(
                  'Sort by Category',
                  style: TextStyle(
                    fontSize: 14,
                    color: GroceryColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildErrorState(BuildContext context) {  // Add BuildContext parameter
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 64 : 48,
            color: GroceryColors.error,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading products',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: GroceryColors.error,
            ),
          ),
          SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // Trigger rebuild
              (context as Element).markNeedsBuild();
            },
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: GroceryColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: GroceryColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}
