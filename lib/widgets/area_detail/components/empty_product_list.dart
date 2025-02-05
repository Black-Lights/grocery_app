import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';

class EmptyProductList extends StatelessWidget {
  final Area area;
  final VoidCallback onAddProduct;
  final bool isTablet;

  const EmptyProductList({
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 40 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Area Icon with Animation
            Container(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: GroceryColors.skyBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAreaIcon(area.name),
                size: isTablet ? 64 : 48,
                color: GroceryColors.teal,
              ),
            ),
            SizedBox(height: isTablet ? 32 : 24),

            // Area Name
            Text(
              area.name,
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.w600,
                color: GroceryColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            if (area.description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                area.description,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: GroceryColors.grey400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: isTablet ? 40 : 32),

            // Empty State Message
            Container(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: GroceryColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: GroceryColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: GroceryColors.navy.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: isTablet ? 48 : 40,
                      color: GroceryColors.teal,
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 20),
                  Text(
                    'No Products Yet',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.w600,
                      color: GroceryColors.navy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding products to keep track of your items',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: GroceryColors.grey400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  ElevatedButton.icon(
                    onPressed: onAddProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GroceryColors.teal,
                      foregroundColor: GroceryColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 24,
                        vertical: isTablet ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.add,
                      size: isTablet ? 24 : 20,
                    ),
                    label: Text(
                      'Add First Product',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Tips Section
            if (isTablet) ...[
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: GroceryColors.skyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: GroceryColors.teal,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Quick Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: GroceryColors.navy,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTip(
                      icon: Icons.calendar_today_outlined,
                      text: 'Track expiry dates to reduce food waste',
                    ),
                    SizedBox(height: 12),
                    _buildTip(
                      icon: Icons.category_outlined,
                      text: 'Organize products by categories',
                    ),
                    SizedBox(height: 12),
                    _buildTip(
                      icon: Icons.notes_outlined,
                      text: 'Add notes for special storage instructions',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTip({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GroceryColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: GroceryColors.teal,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: GroceryColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}
