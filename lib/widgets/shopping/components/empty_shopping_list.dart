import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class EmptyShoppingList extends StatelessWidget {
  const EmptyShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              color: GroceryColors.skyBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: isTablet ? 80 : 64,
              color: GroceryColors.teal,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Your shopping list is empty',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Add items to your shopping list',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: GroceryColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}
