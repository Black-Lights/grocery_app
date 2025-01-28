import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarcodeService {
  final _barcodeScanner = BarcodeScanner(formats: [
    BarcodeFormat.all,
  ]);

  Future<ProductInfo?> scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        return null;
      }

      // Get the first barcode found
      final barcode = barcodes.first;
      print('Barcode found: ${barcode.rawValue}');

      // Look up product information using the barcode
      if (barcode.rawValue != null) {
        return await _lookupProduct(barcode.rawValue!);
      }

      return null;
    } catch (e) {
      print('Error scanning barcode: $e');
      return null;
    } finally {
      _barcodeScanner.close();
    }
  }

  Future<ProductInfo?> _lookupProduct(String barcode) async {
    try {
      // Using Open Food Facts API as an example
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          return ProductInfo(
            name: product['product_name'] ?? '',
            brand: product['brands'] ?? '',
            category: product['categories_tags']?.first?.toString() ?? '',
            imageUrl: product['image_url'],
            ingredients: product['ingredients_text'] ?? '',
            barcode: barcode,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error looking up product: $e');
      return null;
    }
  }
}

class ProductInfo {
  final String name;
  final String brand;
  final String category;
  final String? imageUrl;
  final String ingredients;
  final String barcode;

  ProductInfo({
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl,
    required this.ingredients,
    required this.barcode,
  });

  @override
  String toString() {
    return 'ProductInfo(name: $name, brand: $brand, category: $category)';
  }
}
