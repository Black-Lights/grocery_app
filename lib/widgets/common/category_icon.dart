import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CategoryIcon extends StatelessWidget {
  final String iconPath;
  final bool isSelected;
  final double size;
  final bool isDropdown;

  const CategoryIcon({
    Key? key,
    required this.iconPath,
    this.isSelected = false,
    this.size = 48.0,
    this.isDropdown = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDropdown
            ? (isSelected ? GroceryColors.teal : GroceryColors.navy)
            : GroceryColors.navy,
        borderRadius: BorderRadius.circular(size / 2),
        border: isSelected && !isDropdown
            ? Border.all(
                color: GroceryColors.teal,
                width: 2,
              )
            : null,
      ),
      padding: EdgeInsets.all(size / 6),
      child: Image.asset(
        iconPath,
        fit: BoxFit.contain,
        color: Colors.white,
      ),
    );
  }
}