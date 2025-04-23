import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class EmptyState extends StatelessWidget {
  final bool isLargeScreen;
  final VoidCallback onAddProduct;

  const EmptyState({
    Key? key,
    required this.isLargeScreen,
    required this.onAddProduct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      color: GroceryColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GroceryColors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: isLargeScreen ? 64 : 48,
              color: GroceryColors.teal,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Products Yet',
            style: TextStyle(
              color: GroceryColors.navy,
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Container(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 400 : 300,
            ),
            child: Text(
              'Start by scanning a product label or taking a photo to add your first product',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: isLargeScreen ? 16 : 14,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onPressed: onAddProduct,
                primary: true,
              ),
              SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onPressed: onAddProduct,
                primary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? GroceryColors.teal : GroceryColors.white,
        foregroundColor: primary ? GroceryColors.white : GroceryColors.navy,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 32 : 24,
          vertical: isLargeScreen ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: primary 
                ? Colors.transparent 
                : GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isLargeScreen ? 24 : 20,
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
