import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/text_recognition_service.dart';
import '../../../services/firestore_service.dart';
import 'form_fields.dart';

class ProductDetailsDialog extends StatelessWidget {
  final ProductDetails details;
  final String imagePath;
  final String? areaId;
  final String? selectedAreaId;
  final Function(String?) onAreaSelected;
  final FirestoreService firestoreService;

  const ProductDetailsDialog({
    Key? key,
    required this.details,
    required this.imagePath,
    this.areaId,
    this.selectedAreaId,
    required this.onAreaSelected,
    required this.firestoreService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final nameController = TextEditingController(text: details.name);
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    final manufacturingController = TextEditingController(
      text: details.manufacturingDate?.toString().split(' ')[0] ?? 
           DateTime.now().toString().split(' ')[0],
    );
    final expiryController = TextEditingController(
      text: details.expiryDate?.toString().split(' ')[0] ?? '',
    );

    return Dialog(
      backgroundColor: Color(0xFF1F2041),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: isLargeScreen ? MediaQuery.of(context).size.width * 0.7 : double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isLargeScreen),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLargeScreen)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildImagePreview(imagePath, isLargeScreen),
                                if (details.barcode != null)
                                  _buildBarcodeInfo(isLargeScreen),
                              ],
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: FormFields(
                              nameController: nameController,
                              quantityController: quantityController,
                              unitController: unitController,
                              manufacturingController: manufacturingController,
                              expiryController: expiryController,
                              isLargeScreen: isLargeScreen,
                              areaId: areaId,
                              selectedAreaId: selectedAreaId,
                              onAreaSelected: onAreaSelected,
                              firestoreService: firestoreService,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildImagePreview(imagePath, isLargeScreen),
                          if (details.barcode != null)
                            _buildBarcodeInfo(isLargeScreen),
                          SizedBox(height: 24),
                          FormFields(
                            nameController: nameController,
                            quantityController: quantityController,
                            unitController: unitController,
                            manufacturingController: manufacturingController,
                            expiryController: expiryController,
                            isLargeScreen: isLargeScreen,
                            areaId: areaId,
                            selectedAreaId: selectedAreaId,
                            onAreaSelected: onAreaSelected,
                            firestoreService: firestoreService,
                          ),
                        ],
                      ),

                    if (details.rawText != null && details.rawText!.isNotEmpty)
                      _buildRawTextSection(details.rawText!, isLargeScreen),
                  ],
                ),
              ),
            ),
            _buildActions(context, nameController, quantityController, unitController,
                manufacturingController, expiryController, isLargeScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF19647E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory, color: Color(0xFFFFC857)),
          SizedBox(width: 12),
          Text(
            'Product Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imagePath, bool isLargeScreen) {
    return Container(
      height: isLargeScreen ? 400 : 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF119DA4), width: 2),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBarcodeInfo(bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF4B3F72).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFFFC857).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Color(0xFFFFC857),
                size: isLargeScreen ? 24 : 20,
              ),
              SizedBox(width: 8),
              Text(
                'Barcode Information',
                style: TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: isLargeScreen ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Barcode Display Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Barcode "Image"
                Container(
                  height: 60,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF1F2041),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      12,
                      (index) => Container(
                        width: 3,
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        color: Colors.white,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                // Barcode Number
                Text(
                  details.barcode ?? '',
                  style: TextStyle(
                    color: Color(0xFF1F2041),
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Product Information
          if (details.brand != null && details.brand!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.business,
              label: 'Brand',
              value: details.brand!,
              isLargeScreen: isLargeScreen,
            ),
            SizedBox(height: 8),
          ],

          if (details.ingredients != null && details.ingredients!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.receipt_long,
              label: 'Ingredients',
              value: details.ingredients!,
              isLargeScreen: isLargeScreen,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isLargeScreen,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Color(0xFFFFC857).withOpacity(0.7),
          size: isLargeScreen ? 20 : 16,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isLargeScreen ? 14 : 12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLargeScreen ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRawTextSection(String rawText, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        ExpansionTile(
          title: Text(
            'Raw Detected Text',
            style: TextStyle(
              color: Color(0xFFFFC857),
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF4B3F72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rawText,
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: isLargeScreen ? 14 : 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController quantityController,
    TextEditingController unitController,
    TextEditingController manufacturingController,
    TextEditingController expiryController,
    bool isLargeScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Color(0xFF4B3F72),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFFFC857),
                fontSize: isLargeScreen ? 16 : 14,
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _saveProduct(
              context,
              nameController,
              quantityController,
              unitController,
              manufacturingController,
              expiryController,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF119DA4),
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 32 : 24,
                vertical: isLargeScreen ? 16 : 12,
              ),
            ),
            child: Text(
              'Save Product',
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController quantityController,
    TextEditingController unitController,
    TextEditingController manufacturingController,
    TextEditingController expiryController,
  ) async {
    try {
      final String? finalAreaId = areaId ?? selectedAreaId;
      
      if (finalAreaId == null) {
        throw Exception('Please select an area');
      }

      if (nameController.text.trim().isEmpty ||
          quantityController.text.trim().isEmpty ||
          expiryController.text.trim().isEmpty) {
        throw Exception('Please fill all required fields');
      }

      final quantity = double.tryParse(quantityController.text.trim());
      if (quantity == null || quantity <= 0) {
        throw Exception('Please enter a valid quantity');
      }

      DateTime manufacturingDate = DateTime.parse(
        manufacturingController.text.trim(),
      );
      DateTime expiryDate = DateTime.parse(
        expiryController.text.trim(),
      );

      await firestoreService.addProduct(
        finalAreaId,
        name: nameController.text.trim(),
        category: 'General',
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
        quantity: quantity,
        unit: unitController.text.trim(),
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
