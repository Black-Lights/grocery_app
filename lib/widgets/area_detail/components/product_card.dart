import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddToShoppingList;
  final bool isTablet;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onAddToShoppingList,
    required this.isTablet,
  }) : super(key: key);

  String _getExpiryText(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    if (daysUntilExpiry > 365) {
      final years = (daysUntilExpiry / 365).floor();
      return '$years year${years > 1 ? 's' : ''} left';
    } else if (daysUntilExpiry > 30) {
      final months = (daysUntilExpiry / 30).floor();
      return '$months month${months > 1 ? 's' : ''} left';
    } else if (daysUntilExpiry > 0) {
      return '$daysUntilExpiry day${daysUntilExpiry > 1 ? 's' : ''} left';
    } else if (daysUntilExpiry == 0) {
      return 'Expires today';
    } else {
      return 'Expired';
    }
  }

  Color _getExpiryColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return GroceryColors.error;
    } else if (daysUntilExpiry < 7) {
      return GroceryColors.warning;
    } else {
      return GroceryColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiryText = _getExpiryText(product.expiryDate);
    final expiryColor = _getExpiryColor(product.expiryDate);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: Padding( // Removed InkWell here
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GroceryColors.skyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: GroceryColors.teal,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: 16),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: GroceryColors.navy,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: GroceryColors.skyBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: GroceryColors.skyBlue.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: GroceryColors.teal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: expiryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: expiryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              expiryText,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: expiryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Product Info Grid
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GroceryColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildInfoItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Quantity',
                    value: '${product.quantity} ${product.unit}',
                  ),
                  SizedBox(width: 24),
                  _buildInfoItem(
                    icon: Icons.event_outlined,
                    label: 'Expiry',
                    value: product.expiryDate.toString().split(' ')[0],
                  ),
                  if (isTablet) ...[
                    SizedBox(width: 24),
                    _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Manufacturing',
                      value: product.manufacturingDate.toString().split(' ')[0],
                    ),
                  ],
                ],
              ),
            ),
            
            // Notes Section (if exists)
            if (product.notes?.isNotEmpty ?? false) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GroceryColors.skyBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GroceryColors.skyBlue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_outlined,
                          size: isTablet ? 20 : 16,
                          color: GroceryColors.teal,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: GroceryColors.teal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      product.notes!,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: GroceryColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Action Buttons
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.add_shopping_cart_outlined,
                  label: isTablet ? 'Add to List' : '',
                  onPressed: onAddToShoppingList,
                  color: GroceryColors.teal,
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  label: isTablet ? 'Edit' : '',
                  onPressed: onEdit,
                  color: GroceryColors.navy,
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: isTablet ? 'Delete' : '',
                  onPressed: onDelete,
                  color: GroceryColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isTablet ? 20 : 16,
                color: GroceryColors.grey400,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: GroceryColors.grey400,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: GroceryColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isTablet ? 24 : 20,
                color: color,
              ),
              if (label.isNotEmpty) ...[
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
