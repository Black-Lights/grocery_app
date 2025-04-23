import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme.dart';

class ImageSourceDialog extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const ImageSourceDialog({
    Key? key,
    required this.onSourceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final dialogWidth = isTablet 
        ? MediaQuery.of(context).size.width * 0.4 
        : MediaQuery.of(context).size.width * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              decoration: BoxDecoration(
                color: GroceryColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: GroceryColors.teal,
                    size: isTablet ? 28 : 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Product Image',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: GroceryColors.navy,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Choose how you want to add the product image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: GroceryColors.grey400,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSourceOption(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        description: 'Take a photo',
                        source: ImageSource.camera,
                        isTablet: isTablet,
                        primary: true,
                      ),
                      SizedBox(width: 16),
                      _buildSourceOption(
                        context: context,
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        description: 'Choose existing',
                        source: ImageSource.gallery,
                        isTablet: isTablet,
                        primary: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              decoration: BoxDecoration(
                color: GroceryColors.background,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: GroceryColors.grey400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required ImageSource source,
    required bool isTablet,
    required bool primary,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.back();
            onSourceSelected(source);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary 
                  ? GroceryColors.teal.withOpacity(0.1)
                  : GroceryColors.skyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primary
                    ? GroceryColors.teal.withOpacity(0.3)
                    : GroceryColors.skyBlue.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary
                        ? GroceryColors.teal.withOpacity(0.1)
                        : GroceryColors.skyBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isTablet ? 32 : 28,
                    color: primary
                        ? GroceryColors.teal
                        : GroceryColors.navy,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: primary
                        ? GroceryColors.teal
                        : GroceryColors.navy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: GroceryColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
