import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../pages/shopping_list_page.dart';

class AreaHeader extends StatelessWidget {
  final Area area;
  final VoidCallback onAddProduct;
  final bool isTablet;

  const AreaHeader({
    Key? key,
    required this.area,
    required this.onAddProduct,
    required this.isTablet,
  }) : super(key: key);

  IconData _getAreaIcon(String areaName) {
    switch (areaName.toLowerCase()) {
      case 'refrigerator':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.kitchen_outlined;
      case 'cabinet':
        return Icons.door_sliding;
      case 'counter':
        return Icons.countertops;
      default:
        return Icons.storage;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    if (isTablet) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : color.withOpacity(0.1),
          foregroundColor: isPrimary ? GroceryColors.white : color,
          elevation: isPrimary ? 0 : 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: color.withOpacity(0.2)),
          ),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: !isPrimary
              ? Border.all(color: color.withOpacity(0.2))
              : null,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: isPrimary ? GroceryColors.white : color,
            size: 24,
          ),
          tooltip: label,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: GroceryColors.navy,
              size: isTablet ? 24 : 20,
            ),
            tooltip: 'Back',
          ),
          SizedBox(width: isTablet ? 16 : 8),

          // Area Icon and Info
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: GroceryColors.skyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAreaIcon(area.name),
                    color: GroceryColors.teal,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.w600,
                          color: GroceryColors.navy,
                        ),
                      ),
                      if (area.description.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          area.description,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: GroceryColors.grey400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            children: [
              // Shopping List Button
              _buildActionButton(
                icon: Icons.shopping_cart_outlined,
                label: isTablet ? 'Shopping List' : '',
                onPressed: () => Get.to(() => ShoppingListPage()),
                color: GroceryColors.teal,
              ),
              SizedBox(width: isTablet ? 16 : 8),
              // Add Product Button
              _buildActionButton(
                icon: Icons.add,
                label: isTablet ? 'Add Product' : '',
                onPressed: onAddProduct,
                color: GroceryColors.navy,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
