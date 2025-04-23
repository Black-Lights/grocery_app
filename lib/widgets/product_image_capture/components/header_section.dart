import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class HeaderSection extends StatelessWidget {
  final bool isLargeScreen;  // Changed to isLargeScreen
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final bool processing;

  const HeaderSection({
    Key? key,
    required this.isLargeScreen,  // Changed to isLargeScreen
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.processing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: GroceryColors.white,
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Section
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
            decoration: BoxDecoration(
              color: GroceryColors.background,
              border: Border(
                bottom: BorderSide(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.document_scanner_outlined,
                  color: GroceryColors.teal,
                  size: isLargeScreen ? 32 : 28,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Product',
                        style: TextStyle(
                          color: GroceryColors.navy,
                          fontSize: isLargeScreen ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Add products by scanning labels',
                        style: TextStyle(
                          color: GroceryColors.grey400,
                          fontSize: isLargeScreen ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Section
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Take Photo',
                    onPressed: processing ? null : onCameraPressed,
                    primary: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onPressed: processing ? null : onGalleryPressed,
                    primary: false,
                  ),
                ),
              ],
            ),
          ),

          // Processing Indicator
          if (processing)
            Container(
              padding: EdgeInsets.only(bottom: isLargeScreen ? 24 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GroceryColors.teal,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Processing image...',
                    style: TextStyle(
                      color: GroceryColors.grey400,
                      fontSize: isLargeScreen ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
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
        mainAxisAlignment: MainAxisAlignment.center,
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
