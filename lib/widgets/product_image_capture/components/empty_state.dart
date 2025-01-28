import 'package:flutter/material.dart';

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
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: isLargeScreen ? 80 : 60,
              color: Color(0xFF4B3F72),
            ),
            SizedBox(height: 24),
            Text(
              'No Products Yet',
              style: TextStyle(
                color: Color(0xFFFFC857),
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Start by scanning a product label',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isLargeScreen ? 16 : 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddProduct,
              icon: Icon(Icons.add_a_photo),
              label: Text('Add First Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF119DA4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 32 : 24,
                  vertical: isLargeScreen ? 16 : 12,
                ),
                textStyle: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
