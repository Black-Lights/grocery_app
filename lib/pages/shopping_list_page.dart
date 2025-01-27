import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  bool isLoading = false;

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
                Get.back();
                Get.snackbar(
                  'Success',
                  'Item deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back();
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
    );
  }

  void _addItem() async {
    final name = _itemController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Parse quantity with proper decimal handling
      final quantityText = _quantityController.text.trim();
      double quantity;
      if (quantityText.isEmpty) {
        quantity = 1.0;
      } else {
        quantity = double.tryParse(quantityText) ?? 1.0;
        // Remove trailing zeros after decimal point
        if (quantity == quantity.roundToDouble()) {
          quantity = quantity.toInt().toDouble();
        }
      }

      await _shoppingService.addItem(
        name,
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
      width: double.infinity,
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
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : inputWidth,
          ),
          child: isLandscape && !isTablet
              ? _buildLandscapeInputs(isTablet, padding)
              : _buildPortraitInputs(isTablet, padding),
        ),
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
                                    await _shoppingService.toggleItem(
                                      item.id,
                                      value,
                                    );
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
                                        ? '${item.quantity} ${item.unit}'
                                        : item.quantity.toString(),
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () => _showDeleteConfirmation(item),
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
