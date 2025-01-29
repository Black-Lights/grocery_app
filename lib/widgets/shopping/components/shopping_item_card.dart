import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/shopping_item.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final Function(bool?) onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShoppingItemCard({
    Key? key,
    required this.item,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onToggleComplete(!item.isCompleted),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Transform.scale(
                  scale: isTablet ? 1.2 : 1.0,
                  child: Checkbox(
                    value: item.isCompleted,
                    onChanged: onToggleComplete,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    activeColor: GroceryColors.teal,
                    side: BorderSide(
                      color: GroceryColors.skyBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),

              // Item Details
              Expanded(
                child: Row(
                  children: [
                    // Name
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w500,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isCompleted
                              ? GroceryColors.grey400
                              : GroceryColors.navy,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),

                    // Quantity Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? GroceryColors.grey100
                            : GroceryColors.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: item.isCompleted
                              ? GroceryColors.grey200
                              : GroceryColors.skyBlue.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        item.unit.isNotEmpty
                            ? '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit}'
                            : item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1),
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w500,
                          color: item.isCompleted
                              ? GroceryColors.grey400
                              : GroceryColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit_outlined,
                          size: isTablet ? 24 : 20,
                          color: GroceryColors.teal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 4),

                  // Delete Button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline,
                          size: isTablet ? 24 : 20,
                          color: GroceryColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
