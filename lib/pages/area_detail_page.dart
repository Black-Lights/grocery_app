import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../models/area.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../widgets/area_detail/components/area_sidebar.dart';
import '../widgets/area_detail/components/area_selection_header.dart';
import '../widgets/area_detail/components/product_list.dart';
import '../widgets/area_detail/dialogs/add_product_selection_dialog.dart';

class AreaDetailPage extends StatefulWidget {
  final Area area;

  const AreaDetailPage({
    Key? key,
    required this.area,
  }) : super(key: key);

  @override
  State<AreaDetailPage> createState() => _AreaDetailPageState();
}

class _AreaDetailPageState extends State<AreaDetailPage> {
  final FirestoreService _firestoreService = Get.find();
   late Area currentArea;
  final RxBool _isAllItems = false.obs;
  final Rx<Future<List<Product>>?> _allProductsFuture = Rx<Future<List<Product>>?>(null);

  @override
  void initState() {
    super.initState();
    currentArea = widget.area;
    if (_isAllItems.value) {
      _refreshAllProducts();
    }
  }

  void _refreshAllProducts() {
    _allProductsFuture.value = _firestoreService.getAllProducts();
  }

  void _handleAreaSelected(Area area) {
    setState(() {
      if (area.id == 'all') {
        _isAllItems.value = true;
        _refreshAllProducts();
      } else {
        _isAllItems.value = false;
        currentArea = area;
      }
    });
  }

  

  void _showAddProductDialog() {
    if (_isAllItems.value) {
      Get.snackbar(
        'Note',
        'Please select a specific area to add products',
        backgroundColor: GroceryColors.warning,
        colorText: GroceryColors.white,
      );
      return;
    }

    Get.dialog(
      AddProductSelectorDialog(
        area: currentArea,
        firestoreService: _firestoreService,
      ),
    );
  }


  Widget _buildProductStats(List<Product> products) {
    final totalProducts = products.length;
    final expiredProducts = products.where((p) => p.expiryDate.isBefore(DateTime.now())).length;
    final expiringProducts = products.where((p) {
      final daysUntilExpiry = p.expiryDate.difference(DateTime.now()).inDays;
      return daysUntilExpiry > 0 && daysUntilExpiry <= 7;
    }).length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GroceryColors.white,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.inventory_2_outlined,
              label: 'Total',
              value: totalProducts.toString(),
              color: GroceryColors.teal,
            ),
            if (expiringProducts > 0)
              _buildStatItem(
                icon: Icons.warning_amber_outlined,
                label: 'Expiring Soon',
                value: expiringProducts.toString(),
                color: GroceryColors.warning,
              ),
            if (expiredProducts > 0)
              _buildStatItem(
                icon: Icons.error_outline,
                label: 'Expired',
                value: expiredProducts.toString(),
                color: GroceryColors.error,
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 8),
            Text(
              '$value $label',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    return Obx(() {
      if (_isAllItems.value) {
        if (_allProductsFuture.value == null) {
          _refreshAllProducts();
          return Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<List<Product>>(
          future: _allProductsFuture.value,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading products',
                      style: TextStyle(color: GroceryColors.error),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshAllProducts,
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GroceryColors.teal,
                      ),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: () async => _refreshAllProducts(),
              child: Column(
                children: [
                  _buildProductStats(products),
                  Expanded(
                    child: ProductList(
                      products: products,
                      area: currentArea,
                      isTablet: MediaQuery.of(context).size.width > 600,
                      onAddProduct: _showAddProductDialog,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        return StreamBuilder<List<Product>>(
          stream: _firestoreService.getAreaProducts(currentArea.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildProductStats(snapshot.data!),
                Expanded(
                  child: ProductList(
                    products: snapshot.data!,
                    area: currentArea,
                    isTablet: MediaQuery.of(context).size.width > 600,
                    onAddProduct: _showAddProductDialog,
                  ),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      return Scaffold(
        backgroundColor: GroceryColors.background,
        body: Row(
          children: [
            AreaSidebar(
              currentArea: currentArea,
              onAreaSelected: _handleAreaSelected,
              isTablet: true,
            ),
            Expanded(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: GroceryColors.navy,
                    title: Text(_isAllItems.value ? 'All Items' : currentArea.name),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined),
                        onPressed: () => Get.toNamed('/shopping-list'),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  Expanded(child: _buildProductContent()),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Obx(() => !_isAllItems.value ? FloatingActionButton(
          onPressed: _showAddProductDialog,
          backgroundColor: GroceryColors.teal,
          child: Icon(Icons.add, color: GroceryColors.white),
          tooltip: 'Add Product',
        ) : SizedBox.shrink()),
      );
    }

    // Mobile Layout
    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: AppBar(
        backgroundColor: GroceryColors.navy,
        title: Text(_isAllItems.value ? 'All Items' : 'Storage'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () => Get.toNamed('/shopping-list'),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          AreaSelectionHeader(
            currentArea: currentArea,
            onAreaSelected: _handleAreaSelected,
          ),
          Expanded(child: _buildProductContent()),
        ],
      ),
      floatingActionButton: Obx(() => !_isAllItems.value ? FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: GroceryColors.teal,
        child: Icon(Icons.add, color: GroceryColors.white),
        tooltip: 'Add Product',
      ) : SizedBox.shrink()),
    );
  }
}
