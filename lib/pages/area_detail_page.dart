import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../models/area.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/shopping_service.dart';
import '../widgets/area_detail/components/area_sidebar.dart';
import '../widgets/area_detail/components/area_header.dart';
import '../widgets/area_detail/components/product_list.dart';
import '../widgets/area_detail/dialogs/add_edit_product_dialog.dart';

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
  final FirestoreService _firestoreService = FirestoreService();
  final ShoppingService _shoppingService = ShoppingService();
  late Area currentArea;

  @override
  void initState() {
    super.initState();
    currentArea = widget.area;
  }

  void _handleAreaSelected(Area area) {
    if (area.id != currentArea.id) {
      setState(() {
        currentArea = area;
      });
    }
  }

  void _showAddProductDialog() {
    Get.dialog(
      AddEditProductDialog(
        area: currentArea,
        isTablet: MediaQuery.of(context).size.width > 600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (isTablet) {
      return Scaffold(
        backgroundColor: GroceryColors.background,
        body: Row(
          children: [
            // Left Sidebar with Areas
            AreaSidebar(
              currentArea: currentArea,
              onAreaSelected: _handleAreaSelected,
              isTablet: true,
            ),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Header with Actions
                  AreaHeader(
                    area: currentArea,
                    onAddProduct: _showAddProductDialog,
                    isTablet: true,
                  ),

                  // Product List
                  Expanded(
                    child: ProductList(
                      area: currentArea,
                      isTablet: true,
                      onAddProduct: _showAddProductDialog,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddProductDialog,
          backgroundColor: GroceryColors.teal,
          child: Icon(Icons.add, color: GroceryColors.white),
          tooltip: 'Add Product',
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      backgroundColor: GroceryColors.background,
      body: Row(
        children: [
          // Collapsed Sidebar with Icons Only
          AreaSidebar(
            currentArea: currentArea,
            onAreaSelected: _handleAreaSelected,
            isTablet: false,
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header with Actions
                AreaHeader(
                  area: currentArea,
                  onAddProduct: _showAddProductDialog,
                  isTablet: false,
                ),

                // Product List
                Expanded(
                  child: ProductList(
                    area: currentArea,
                    isTablet: false,
                    onAddProduct: _showAddProductDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: GroceryColors.teal,
        child: Icon(Icons.add, color: GroceryColors.white),
        tooltip: 'Add Product',
      ),
    );
  }
}


// Food Categories List
const List<String> foodCategories = [
  'Fruits',
  'Vegetables',
  'Dairy',
  'Meat',
  'Poultry',
  'Seafood',
  'Grains',
  'Bread',
  'Pasta',
  'Snacks',
  'Beverages',
  'Condiments',
  'Sauces',
  'Spices',
  'Herbs',
  'Baking Supplies',
  'Canned Goods',
  'Frozen Foods',
  'Ready-to-eat Meals',
  'Breakfast Foods',
  'Desserts',
  'Nuts and Seeds',
  'Oils and Vinegars',
  'Processed Foods',
  'Baby Food',
  'Pet Food',
  'Health Foods',
  'Organic Products',
  'Gluten-free Products',
  'International Foods',
  'Others'
];
