import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/product.dart';

class ShoppingSuggestions extends StatelessWidget {
  final List<Product> suggestions;
  final Function(Product) onSuggestionSelected;

  const ShoppingSuggestions({
    Key? key,
    required this.suggestions,
    required this.onSuggestionSelected,
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
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GroceryColors.skyBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: isTablet ? 24 : 16,
          endIndent: isTablet ? 24 : 16,
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
        itemBuilder: (context, index) {
          final product = suggestions[index];
          final expiryText = _getExpiryText(product.expiryDate);
          final expiryColor = _getExpiryColor(product.expiryDate);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSuggestionSelected(product),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 16 : 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: GroceryColors.navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: GroceryColors.skyBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: GroceryColors.skyBlue.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  '${product.quantity} ${product.unit}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: GroceryColors.teal,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: expiryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
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
                    Icon(
                      Icons.add_circle_outline,
                      color: GroceryColors.teal,
                      size: isTablet ? 24 : 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
