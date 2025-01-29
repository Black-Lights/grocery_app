import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../services/firestore_service.dart';
import '../services/shopping_service.dart';
import '../widgets/shopping/components/shopping_input.dart';
import '../widgets/shopping/components/shopping_suggestions.dart';
import '../widgets/shopping/components/shopping_list.dart';
class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final ShoppingService _shoppingService = ShoppingService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _unitController = TextEditingController();
  
  List<Product> _suggestions = [];
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _itemController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().length < 2) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);

      try {
        final results = await _firestoreService.searchProducts(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isSearching = false;
          });
          Get.snackbar(
            'Error',
            'Failed to search products',
            backgroundColor: GroceryColors.error,
            colorText: GroceryColors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    });
  }

  void _handleSuggestionSelected(Product product) {
    setState(() {
      _itemController.text = product.name;
      _unitController.text = product.unit;
      _suggestions = [];
    });
    FocusScope.of(context).nextFocus();
  }

  Future<void> _addItem() async {
    final name = _itemController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
      await _shoppingService.addItem(
        name: name,
        quantity: quantity,
        unit: _unitController.text.trim(),
      );
      
      _itemController.clear();
      _quantityController.text = '1';
      _unitController.clear();
      _suggestions = [];

      Get.snackbar(
        'Success',
        'Item added to shopping list',
        backgroundColor: GroceryColors.success,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCompletedItems() async {
    try {
      await _shoppingService.deleteCompletedItems();
      Get.snackbar(
        'Success',
        'Completed items removed',
        backgroundColor: GroceryColors.success,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove completed items',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: GroceryColors.background,
        appBar: AppBar(
          title: Text(
            'Shopping List',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Tooltip(
              message: 'Clear completed items',
              child: IconButton(
                icon: Icon(
                  Icons.cleaning_services_outlined,
                  size: isTablet ? 28 : 24,
                  color: GroceryColors.white,
                ),
                onPressed: _clearCompletedItems,
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Input Section
            Container(
              color: GroceryColors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShoppingInput(
                    itemController: _itemController,
                    quantityController: _quantityController,
                    unitController: _unitController,
                    isLoading: _isLoading,
                    onSearch: _searchProducts,
                    onAdd: _addItem,
                    isSearching: _isSearching,
                  ),
                  if (_suggestions.isNotEmpty)
                    ShoppingSuggestions(
                      suggestions: _suggestions,
                      onSuggestionSelected: _handleSuggestionSelected,
                    ),
                ],
              ),
            ),

            // Shopping List
            Expanded(
              child: ShoppingList(),
            ),
          ],
        ),
      ),
    );
  }
}
