import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';  // Updated path
import '../../services/text_recognition_service.dart';  // Updated path
import '../../services/firestore_service.dart';  // Updated path
import 'components/header_section.dart';  // Updated path
import 'components/recent_products_section.dart';  // Updated path
import 'components/image_source_dialog.dart';  // Updated path
import 'components/product_details_dialog.dart';  // Updated path


class ProductImageCapture extends StatefulWidget {
  final String? areaId;
  
  const ProductImageCapture({
    Key? key,
    this.areaId,
  }) : super(key: key);

  @override
  _ProductImageCaptureState createState() => _ProductImageCaptureState();
}

class _ProductImageCaptureState extends State<ProductImageCapture> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognitionService _recognitionService = TextRecognitionService();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final RxBool _processing = false.obs;
  final RxString? selectedAreaId = RxString('');

  @override
  void initState() {
    super.initState();
    selectedAreaId?.value = widget.areaId ?? '';
  }

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      _processing.value = true;

      final details = await _recognitionService.processImage(image.path);
      _showProductDetailsDialog(details, image.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process image: ${e.toString()}',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      );
    } finally {
      _processing.value = false;
    }
  }

  void _showProductDetailsDialog(ProductDetails details, String imagePath) {
    Get.dialog(
      ProductDetailsDialog(
        details: details,
        imagePath: imagePath,
        areaId: widget.areaId,
        selectedAreaId: selectedAreaId?.value,
        onAreaSelected: (String? value) {
          selectedAreaId?.value = value ?? '';
        },
        firestoreService: _firestoreService,
      ),
      barrierDismissible: false,
    );
  }

  void _showImageSourceDialog() {
    Get.dialog(
      ImageSourceDialog(
        onSourceSelected: _processImage,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: GroceryColors.background,
      // Remove the AppBar since it's now a tab
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => HeaderSection(
              isLargeScreen: isLargeScreen,
              onCameraPressed: () => _processImage(ImageSource.camera),
              onGalleryPressed: () => _processImage(ImageSource.gallery),
              processing: _processing.value,
            )),
            Expanded(
              child: RecentProductsSection(
                areaId: widget.areaId,
                isLargeScreen: isLargeScreen,
                firestoreService: _firestoreService,
                onAddProduct: _showImageSourceDialog,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (_processing.value) return SizedBox.shrink();
        return FloatingActionButton(
          onPressed: _showImageSourceDialog,
          backgroundColor: GroceryColors.teal,
          child: Icon(Icons.add_a_photo, color: GroceryColors.white),
          tooltip: 'Add Product',
        );
      }),
    );
  }
}
