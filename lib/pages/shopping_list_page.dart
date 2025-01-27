import 'dart:async';
import 'package:grocery/models/product.dart';

import '../models/product_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocery/services/firestore_service.dart';
import '../services/shopping_service.dart';
import '../models/shopping_item.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final ShoppingService _shoppingService = ShoppingService();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _unitController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
   List<Product> _suggestions = [];
  bool _isSearching = false;
  bool isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      print('Searching for: $query'); // Debug print
      
      if (query.trim().length < 2) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
      });

      try {
        final results = await _firestoreService.searchProducts(query);
        print('Found ${results.length} suggestions'); // Debug print
        
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        print('Error in search: $e'); // Debug print
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 8),
      constraints: BoxConstraints(
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final product = _suggestions[index];
          final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
          
          String expiryText;
          if (daysUntilExpiry > 365) {
            final years = (daysUntilExpiry / 365).floor();
            expiryText = '$years year${years > 1 ? 's' : ''} left';
          } else if (daysUntilExpiry > 30) {
            final months = (daysUntilExpiry / 30).floor();
            expiryText = '$months month${months > 1 ? 's' : ''} left';
          } else if (daysUntilExpiry > 0) {
            expiryText = '$daysUntilExpiry day${daysUntilExpiry > 1 ? 's' : ''} left';
          } else if (daysUntilExpiry == 0) {
            expiryText = 'Expires today';
          } else {
            expiryText = 'Expired';
          }

          final expiryColor = daysUntilExpiry < 0
              ? Colors.red
              : daysUntilExpiry < 7
                  ? Colors.orange
                  : Colors.green;

          return ListTile(
            title: Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${product.quantity} ${product.unit}'),
                Text(
                  expiryText,
                  style: TextStyle(color: expiryColor),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _itemController.text = product.name;
                _unitController.text = product.unit;
                _suggestions = [];
              });
              FocusScope.of(context).nextFocus();
            },
          );
        },
      ),
    );
  }



    void _showEditDialog(ShoppingItem item) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitController = TextEditingController(text: item.unit);

    Get.dialog(
      AlertDialog(
        title: Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final quantity = double.tryParse(quantityController.text.trim());
                if (quantity != null) {
                  await _shoppingService.updateItemQuantity(item.id, quantity);
                  await _shoppingService.updateItemUnit(item.id, unitController.text.trim());
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Item updated successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update item',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ShoppingItem item) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}" from your shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _shoppingService.deleteItem(item.id);
                Get.back(); // Close the dialog
                Get.snackbar(
                  'Success',
                  'Item deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete item',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
      barrierDismissible: false, // Prevent closing by tapping outside
    );
  }

  void _addItem() async {
    final name = _itemController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
    });

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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add item',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInputSection(bool isTablet, bool isLandscape, double padding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final inputWidth = isLandscape 
        ? screenWidth * 0.8  // 80% of screen width in landscape
        : screenWidth;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    hintText: 'Item name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  onChanged: _searchProducts,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: isTablet ? 120 : 80,
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    hintText: 'Qty',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: isTablet ? 120 : 80,
                child: TextField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    hintText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                height: isTablet ? 60 : 56,
                width: isTablet ? 60 : 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _addItem,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.add),
                ),
              ),
            ],
          ),
          _buildSuggestionsList(),
        ],
      ),
    );
  }

  Widget _buildPortraitInputs(bool isTablet, double padding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Item Name
        TextField(
          controller: _itemController,
          decoration: InputDecoration(
            hintText: 'Item name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isTablet ? 20 : 16,
            ),
          ),
          style: TextStyle(fontSize: isTablet ? 18 : 16),
          textCapitalization: TextCapitalization.sentences,
        ),
        SizedBox(height: 12),
        // Quantity and Unit Row
        Row(
          children: [
            // Quantity
            Expanded(
              flex: 2,
              child: TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 20 : 16,
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
            ),
            SizedBox(width: 12),
            // Unit
            Expanded(
              flex: 2,
              child: TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  hintText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isTablet ? 20 : 16,
                  ),
                ),
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
            ),
            SizedBox(width: 12),
            // Add Button
            SizedBox(
              height: isTablet ? 60 : 56,
              width: isTablet ? 60 : 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _addItem,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.add, size: isTablet ? 28 : 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeInputs(bool isTablet, double padding) {
    return Row(
      children: [
        // Item Name
        Expanded(
          flex: 4,
          child: TextField(
            controller: _itemController,
            decoration: InputDecoration(
              hintText: 'Item name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isTablet ? 20 : 16,
              ),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        SizedBox(width: 12),
        // Quantity
        SizedBox(
          width: isTablet ? 120 : 100,
          child: TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              hintText: 'Qty',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isTablet ? 20 : 16,
              ),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
          ),
        ),
        SizedBox(width: 12),
        // Unit
        SizedBox(
          width: isTablet ? 120 : 100,
          child: TextField(
            controller: _unitController,
            decoration: InputDecoration(
              hintText: 'Unit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isTablet ? 20 : 16,
              ),
            ),
            style: TextStyle(fontSize: isTablet ? 18 : 16),
          ),
        ),
        SizedBox(width: 12),
        // Add Button
        SizedBox(
          height: isTablet ? 60 : 56,
          width: isTablet ? 60 : 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : _addItem,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.add, size: isTablet ? 28 : 24),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;
    final padding = isTablet ? 32.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping List',
          style: TextStyle(fontSize: isTablet ? 24 : 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services, size: isTablet ? 28 : 24),
            onPressed: () async {
              try {
                await _shoppingService.deleteCompletedItems();
                Get.snackbar(
                  'Success',
                  'Completed items removed',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to remove completed items',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            tooltip: 'Clear completed items',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInputSection(isTablet, isLandscape, padding),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 800 : double.infinity,
                ),
                child: StreamBuilder<List<ShoppingItem>>(
                  stream: _shoppingService.getShoppingList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading shopping list'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: isTablet ? 80 : 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your shopping list is empty',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(padding),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 24 : 16,
                              vertical: isTablet ? 8 : 4,
                            ),
                            leading: Checkbox(
                              value: item.isCompleted,
                              onChanged: (bool? value) async {
                                if (value != null) {
                                  try {
                                    await _shoppingService.toggleItem(item.id, value);
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to update item',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      decoration: item.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.unit.isNotEmpty
                                        ? '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit}'
                                        : item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1),
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(item),
                                  tooltip: 'Edit Item',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline),
                                  onPressed: () => _showDeleteConfirmation(item),
                                  tooltip: 'Delete Item',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
