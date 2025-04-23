import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/product.dart';
import '../../../services/shopping_service.dart';

class AddToShoppingDialog extends StatefulWidget {
  final Product product;
  final bool isTablet;
  final ShoppingService shoppingService; 

  const AddToShoppingDialog({
    Key? key,
    required this.product,
    required this.isTablet,
    required this.shoppingService, 
  }) : super(key: key);

  @override
  State<AddToShoppingDialog> createState() => _AddToShoppingDialogState();
}

class _AddToShoppingDialogState extends State<AddToShoppingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  final _shoppingService = ShoppingService();
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: widget.isTablet ? 400 : double.infinity,
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(widget.isTablet ? 24 : 20),
                decoration: BoxDecoration(
                  color: GroceryColors.teal.withOpacity(0.1),
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
                        Icons.add_shopping_cart,
                        color: GroceryColors.teal,
                        size: widget.isTablet ? 28 : 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Add to Shopping List',
                      style: TextStyle(
                        fontSize: widget.isTablet ? 24 : 20,
                        fontWeight: FontWeight.w600,
                        color: GroceryColors.navy,
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
                    // Product Info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GroceryColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GroceryColors.skyBlue.withOpacity(0.5),
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
                              Icons.inventory_2_outlined,
                              color: GroceryColors.teal,
                              size: widget.isTablet ? 24 : 20,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: GroceryColors.navy,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Unit: ${widget.product.unit}',
                                  style: TextStyle(
                                    fontSize: widget.isTablet ? 14 : 12,
                                    color: GroceryColors.grey400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Quantity Input
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.shopping_cart_outlined),
                        suffixText: widget.product.unit,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quantity';
                        }
                        final quantity = double.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
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
                          horizontal: widget.isTablet ? 24 : 16,
                          vertical: widget.isTablet ? 16 : 12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: widget.isTablet ? 16 : 14,
                          color: GroceryColors.grey400,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Obx(() => ElevatedButton(
                      onPressed: _isLoading.value ? null : () async {
                        if (!_formKey.currentState!.validate()) return;

                        try {
                          _isLoading.value = true;
                          final quantity = double.parse(_quantityController.text.trim());
                          
                          await _shoppingService.addItem(
                            name: widget.product.name,
                            quantity: quantity,
                            unit: widget.product.unit,
                          );

                          Get.back();
                          Get.snackbar(
                            'Success',
                            'Added to shopping list',
                            backgroundColor: GroceryColors.success,
                            colorText: GroceryColors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to add to shopping list',
                            backgroundColor: GroceryColors.error,
                            colorText: GroceryColors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        } finally {
                          _isLoading.value = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GroceryColors.teal,
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isTablet ? 32 : 24,
                          vertical: widget.isTablet ? 16 : 12,
                        ),
                      ),
                      child: _isLoading.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  GroceryColors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Add to List',
                              style: TextStyle(
                                fontSize: widget.isTablet ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    )),
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
