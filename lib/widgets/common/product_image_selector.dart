import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/product_image_service.dart';

class ProductImageSelector extends StatelessWidget {
  final String? imagePath;
  final String? barcode;
  final bool isTablet;
  final Function(String) onImageSelected;
  final ProductImageService _productImageService = ProductImageService();

  ProductImageSelector({
    Key? key,
    this.imagePath,
    this.barcode,
    required this.isTablet,
    required this.onImageSelected,
  }) : super(key: key);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  Widget _buildImagePickerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPickerButton(
          icon: Icons.camera_alt,
          label: 'Camera',
          onTap: () => _pickImage(ImageSource.camera),
        ),
        SizedBox(width: 16),
        _buildPickerButton(
          icon: Icons.photo_library,
          label: 'Gallery',
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: GroceryColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GroceryColors.teal.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? 32 : 24,
              color: GroceryColors.teal,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: GroceryColors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (imagePath == null) {
      return Container(
        height: isTablet ? 300 : 200,
        decoration: BoxDecoration(
          color: GroceryColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: isTablet ? 64 : 48,
              color: GroceryColors.grey300,
            ),
            SizedBox(height: 16),
            Text(
              'Add Product Image',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: GroceryColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24),
            _buildImagePickerButtons(),
          ],
        ),
      );
    }

    return Container(
      height: isTablet ? 300 : 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath!.startsWith('http')
                ? Image.network(
                    imagePath!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GroceryColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: GroceryColors.navy.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit,
                  color: GroceryColors.teal,
                  size: 20,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: Get.context!,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: GroceryColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: GroceryColors.grey200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        _buildImagePickerButtons(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (barcode != null) {
      return FutureBuilder<String?>(
        future: _productImageService.getProductImage(barcode!, imagePath),
        builder: (context, snapshot) {
        return _buildImagePreview();
        },
      );
    }

    return _buildImagePreview();
  }
}
