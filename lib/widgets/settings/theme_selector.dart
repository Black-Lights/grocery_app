import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/theme_service.dart';
import '../../config/theme.dart';

class ThemeSelector extends StatelessWidget {
  final bool showHeader;
  final bool isBottomSheet;

  const ThemeSelector({
    Key? key,
    this.showHeader = true,
    this.isBottomSheet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: GroceryColors.white,
              border: Border(
                bottom: BorderSide(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                if (!isBottomSheet && !isTablet)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: GroceryColors.navy,
                    ),
                    onPressed: () => Get.back(),
                  ),
                Icon(
                  Icons.palette_outlined,
                  color: GroceryColors.navy,
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'App Theme',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: GroceryColors.navy,
                    ),
                  ),
                ),
                if (isBottomSheet)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: GroceryColors.navy,
                    ),
                    onPressed: () => Get.back(),
                  ),
              ],
            ),
          ),
          if (!isBottomSheet)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: 12,
              ),
              child: Text(
                'Choose a theme that suits your style. The app will automatically adjust its appearance based on your selection.',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: GroceryColors.grey400,
                ),
              ),
            ),
        ],
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isTablet ? 24 : 16,
            ),
            children: [
              _buildThemeOption(
                context,
                'Classic Theme',
                'Default light theme with navy and teal colors',
                ThemeType.classic,
                isTablet,
              ),
              _buildThemeOption(
                context,
                'Nature Theme',
                'Fresh and natural green color scheme',
                ThemeType.nature,
                isTablet,
              ),
              _buildThemeOption(
                context,
                'Ocean Theme',
                'Calming blue colors inspired by the sea',
                ThemeType.ocean,
                isTablet,
              ),
              _buildThemeOption(
                context,
                'Sunset Theme',
                'Warm and cozy colors for a comfortable feel',
                ThemeType.sunset,
                isTablet,
              ),
              _buildThemeOption(
                context,
                'Dark Theme',
                'Easy on the eyes with dark mode colors',
                ThemeType.dark,
                isTablet,
              ),
              // Add some bottom padding for better scrolling
              SizedBox(height: isBottomSheet ? 16 : 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String subtitle,
    ThemeType type,
    bool isTablet,
  ) {
    final themeService = Get.find<ThemeService>();

    return Obx(() {
      final isSelected = themeService.currentTheme.value == type;
      
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
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
          onTap: () => themeService.saveTheme(type),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 56 : 48,
                  height: isTablet ? 56 : 48,
                  decoration: BoxDecoration(
                    color: _getThemeColor(type),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? GroceryColors.teal
                          : Colors.transparent,
                      width: 2,
                    ),
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
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? GroceryColors.teal : GroceryColors.navy,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: GroceryColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: GroceryColors.teal,
                    size: isTablet ? 28 : 24,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Color _getThemeColor(ThemeType type) {
    switch (type) {
      case ThemeType.classic:
        return GroceryColors.navy;
      case ThemeType.nature:
        return Color(0xFF2D5A27);
      case ThemeType.ocean:
        return Color(0xFF1A237E);
      case ThemeType.sunset:
        return Color(0xFF5D4037);
      case ThemeType.dark:
        return Color(0xFF212121);
    }
  }
}
