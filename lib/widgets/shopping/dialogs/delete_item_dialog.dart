import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/shopping_item.dart';

class DeleteItemDialog extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onDelete;

  const DeleteItemDialog({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GroceryColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: GroceryColors.error,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Delete Item',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.w600,
                    color: GroceryColors.navy,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Warning Message
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GroceryColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: GroceryColors.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: GroceryColors.error,
                    size: isTablet ? 24 : 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Are you sure you want to delete "${item.name}" from your shopping list?',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: GroceryColors.navy,
                      ),
                    ),
                  ),
                ],
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
                // Delete Button
                ElevatedButton(
                  onPressed: () {
                    onDelete();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GroceryColors.error,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    'Delete',
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
