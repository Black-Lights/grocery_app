import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/text_recognition_service.dart';
import '../../services/firestore_service.dart';
import '../../models/area.dart';
import '../../models/product.dart';
import 'components/header_section.dart';
import 'components/recent_products_section.dart';
import 'components/image_source_dialog.dart';
import 'components/product_details_dialog.dart';
export 'product_image_capture.dart';

class ProductImageCapture extends StatefulWidget {
  final String? areaId;
  
  const ProductImageCapture({
    super.key,
    this.areaId,
  });

  @override
  _ProductImageCaptureState createState() => _ProductImageCaptureState();
}

class _ProductImageCaptureState extends State<ProductImageCapture> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognitionService _recognitionService = TextRecognitionService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _processing = false;
  String? selectedAreaId;

  @override
  void initState() {
    super.initState();
    selectedAreaId = widget.areaId;
  }

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      setState(() {
        _processing = true;
      });

      final details = await _recognitionService.processImage(image.path);
      _showProductDetailsDialog(details, image.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  void _showProductDetailsDialog(ProductDetails details, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(
        details: details,
        imagePath: imagePath,
        areaId: widget.areaId,
        selectedAreaId: selectedAreaId,
        onAreaSelected: (String? value) {
          setState(() {
            selectedAreaId = value;
          });
        },
        firestoreService: _firestoreService,
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => ImageSourceDialog(
        onSourceSelected: _processImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Color(0xFF1F2041),
      body: Column(
        children: [
          HeaderSection(
            isLargeScreen: isLargeScreen,
            onCameraPressed: () => _processImage(ImageSource.camera),
            onGalleryPressed: () => _processImage(ImageSource.gallery),
            processing: _processing,
          ),
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
    );
  }
}
