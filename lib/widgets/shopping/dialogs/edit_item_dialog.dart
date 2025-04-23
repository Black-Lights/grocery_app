import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/shopping_item.dart';

class EditItemDialog extends StatelessWidget {
  final ShoppingItem item;
  final Function(double quantity, String unit) onUpdate;

  EditItemDialog({
    Key? key,
    required this.item,
    required this.onUpdate,
  }) : super(key: key);

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    // Initialize controllers with current values
    quantityController.text = item.quantity.toString();
    unitController.text = item.unit;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: isTablet ? 400 : double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: GroceryColors.navy.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: GroceryColors.teal,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Edit Item',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w600,
                    color: GroceryColors.navy,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Item Name Display
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GroceryColors.skyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GroceryColors.skyBlue.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: GroceryColors.teal,
                    size: isTablet ? 24 : 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w500,
                        color: GroceryColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Quantity Input
            Text(
              'Quantity',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: GroceryColors.navy,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                prefixIcon: Icon(Icons.numbers, color: GroceryColors.grey300),
              ),
            ),
            SizedBox(height: 16),

            // Unit Input
            Text(
              'Unit',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: GroceryColors.navy,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: unitController,
              decoration: InputDecoration(
                hintText: 'Enter unit (e.g., kg, pcs)',
                prefixIcon: Icon(Icons.straighten, color: GroceryColors.grey300),
              ),
            ),
            SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: GroceryColors.grey400,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Update Button
                ElevatedButton(
                  onPressed: () {
                    final quantity = double.tryParse(quantityController.text.trim());
                    if (quantity != null) {
                      onUpdate(quantity, unitController.text.trim());
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
