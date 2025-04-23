import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isTablet;
  final Widget? trailing;

  const SettingsMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isSelected,
    required this.isTablet,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? GroceryColors.teal.withOpacity(0.1) : GroceryColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? GroceryColors.teal
              : GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GroceryColors.teal.withOpacity(0.1)
                      : GroceryColors.skyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? GroceryColors.teal : GroceryColors.navy,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? GroceryColors.teal : GroceryColors.navy,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: GroceryColors.grey400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: trailing!,
                ),
              Icon(
                Icons.chevron_right,
                color: isSelected ? GroceryColors.teal : GroceryColors.grey400,
                size: isTablet ? 24 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
