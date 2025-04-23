import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class ShoppingInput extends StatelessWidget {
  final TextEditingController itemController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final bool isLoading;
  final Function(String) onSearch;
  final VoidCallback onAdd;
  final bool isSearching;

  const ShoppingInput({
    Key? key,
    required this.itemController,
    required this.quantityController,
    required this.unitController,
    required this.isLoading,
    required this.onSearch,
    required this.onAdd,
    required this.isSearching,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
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
      child: isLandscape 
        ? _buildLandscapeLayout(isTablet)
        : _buildPortraitLayout(isTablet),
    );
  }

  Widget _buildPortraitLayout(bool isTablet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: itemController,
          decoration: InputDecoration(
            hintText: 'Add item to shopping list',
            hintStyle: TextStyle(color: GroceryColors.grey300),
            prefixIcon: Icon(Icons.search, color: GroceryColors.grey300),
            suffixIcon: isSearching
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
                      ),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: GroceryColors.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: GroceryColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: GroceryColors.teal, width: 2),
            ),
            filled: true,
            fillColor: GroceryColors.white,
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: TextStyle(color: GroceryColors.grey300),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: GroceryColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: GroceryColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: GroceryColors.teal, width: 2),
                  ),
                  filled: true,
                  fillColor: GroceryColors.white,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                controller: unitController,
                decoration: InputDecoration(
                  hintText: 'Unit',
                  hintStyle: TextStyle(color: GroceryColors.grey300),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: GroceryColors.grey200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: GroceryColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: GroceryColors.teal, width: 2),
                  ),
                  filled: true,
                  fillColor: GroceryColors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: isTablet ? 60 : 56,
              width: isTablet ? 60 : 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GroceryColors.teal,
                  foregroundColor: GroceryColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.white),
                        ),
                      )
                    : Icon(Icons.add, size: isTablet ? 28 : 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            controller: itemController,
            decoration: InputDecoration(
              hintText: 'Add item to shopping list',
              hintStyle: TextStyle(color: GroceryColors.grey300),
              prefixIcon: Icon(Icons.search, color: GroceryColors.grey300),
              suffixIcon: isSearching
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
                        ),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.teal, width: 2),
              ),
              filled: true,
              fillColor: GroceryColors.white,
            ),
            onChanged: onSearch,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: isTablet ? 120 : 100,
          child: TextField(
            controller: quantityController,
            decoration: InputDecoration(
              hintText: 'Qty',
              hintStyle: TextStyle(color: GroceryColors.grey300),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.teal, width: 2),
              ),
              filled: true,
              fillColor: GroceryColors.white,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: isTablet ? 120 : 100,
          child: TextField(
            controller: unitController,
            decoration: InputDecoration(
              hintText: 'Unit',
              hintStyle: TextStyle(color: GroceryColors.grey300),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: GroceryColors.teal, width: 2),
              ),
              filled: true,
              fillColor: GroceryColors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: isTablet ? 60 : 56,
          width: isTablet ? 60 : 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.teal,
              foregroundColor: GroceryColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.white),
                    ),
                  )
                : Icon(Icons.add, size: isTablet ? 28 : 24),
          ),
        ),
      ],
    );
  }
}
