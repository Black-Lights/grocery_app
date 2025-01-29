import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../services/text_recognition_service.dart';
import '../../services/firestore_service.dart';
import 'components/header_section.dart';
import 'components/recent_products_section.dart';
import 'components/image_source_dialog.dart';
import 'components/product_details_dialog.dart';

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
      appBar: AppBar(
        backgroundColor: GroceryColors.navy,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GroceryColors.white),
          onPressed: () => Get.back(),
        ),
        // actions: [
        //   Obx(() {
        //     if (_processing.value) {
        //       return Center(
        //         child: Padding(
        //           padding: EdgeInsets.only(right: 16),
        //           child: SizedBox(
        //             width: 20,
        //             height: 20,
        //             child: CircularProgressIndicator(
        //               strokeWidth: 2,
        //               valueColor: AlwaysStoppedAnimation<Color>(
        //                 GroceryColors.teal,
        //               ),
        //             ),
        //           ),
        //         ),
        //       );
        //     }
        //     return IconButton(
        //       icon: Icon(
        //         Icons.add_photo_alternate_outlined,
        //         color: GroceryColors.navy,
        //       ),
        //       onPressed: _showImageSourceDialog,
        //       tooltip: 'Add Product',
        //     );
        //   }),
        //   SizedBox(width: 8),
        // ],
      ),
      body: Column(
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
