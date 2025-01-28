import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/barcode_service.dart';

class BarcodeScannerButton extends StatelessWidget {
  final bool isLargeScreen;
  final Function(ProductInfo) onProductFound;
  final VoidCallback onError;

  const BarcodeScannerButton({
    Key? key,
    required this.isLargeScreen,
    required this.onProductFound,
    required this.onError,
  }) : super(key: key);

  Future<void> _scanBarcode(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      
      if (image == null) return;

      final barcodeService = BarcodeService();
      final productInfo = await barcodeService.scanBarcode(image.path);

      if (productInfo != null) {
        onProductFound(productInfo);
      } else {
        onError();
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _scanBarcode(context),
      icon: Icon(Icons.qr_code_scanner),
      label: Text('Scan Barcode'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF119DA4),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 32 : 24,
          vertical: isLargeScreen ? 16 : 12,
        ),
        textStyle: TextStyle(
          fontSize: isLargeScreen ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
