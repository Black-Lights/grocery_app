import 'dart:developer';
// lib/widgets/area_detail/dialogs/add_product_selector_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../services/firestore_service.dart';
import '../../../services/text_recognition_service.dart';
import '../../product_image_capture/components/product_details_dialog.dart';
import 'add_edit_product_dialog.dart';

class AddProductSelectorDialog extends StatelessWidget {
  final Area area;
  final FirestoreService firestoreService;
  final RxBool isProcessing = false.obs;

  AddProductSelectorDialog({
    Key? key,
    required this.area,
    required this.firestoreService,
  }) : super(key: key);

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        isProcessing.value = true;
        final textRecognitionService = TextRecognitionService();
        final details = await textRecognitionService.processImage(image.path);
        isProcessing.value = false;
        
        Get.back(); // Close selection dialog
        
        Get.dialog(
          ProductDetailsDialog(
            details: details,
            imagePath: image.path,
            firestoreService: firestoreService,
            areaId: area.id,
            onAreaSelected: (String? selectedArea) {},
            isTablet: Get.width > 600,
          ),
        );
      }
    } catch (e) {
      log('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to process image',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
      );
    }
  }

  void _handleManualEntry() {
    Get.back();
    Get.dialog(
      AddEditProductDialog(
        area: area,
        isTablet: Get.width > 600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final dialogWidth = isTablet 
        ? MediaQuery.of(context).size.width * 0.4 
        : MediaQuery.of(context).size.width * 0.85;

    return Obx(() => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: isProcessing.value
            ? Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing Image...',
                      style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            : Column(
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
                    Icons.add_circle_outline,
                    color: GroceryColors.teal,
                    size: isTablet ? 28 : 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Product',
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
                    'Choose how you want to add the product',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: GroceryColors.grey400,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      _buildOption(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        description: 'Scan product',
                        onTap: () => _handleImageSelection(ImageSource.camera),
                        isTablet: isTablet,
                        primary: true,
                      ),
                      SizedBox(width: 16),
                      _buildOption(
                        context: context,
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        description: 'Choose image',
                        onTap: () => _handleImageSelection(ImageSource.gallery),
                        isTablet: isTablet,
                        primary: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildOption(
                    context: context,
                    icon: Icons.edit_note_outlined,
                    label: 'Manual Entry',
                    description: 'Add details manually',
                    onTap: _handleManualEntry,
                    isTablet: isTablet,
                    primary: false,
                    fullWidth: true,
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
    )
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
    required bool isTablet,
    required bool primary,
    bool fullWidth = false,
  }) {
    final optionWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
    );

    return fullWidth
        ? optionWidget
        : Expanded(child: optionWidget);
  }
}
