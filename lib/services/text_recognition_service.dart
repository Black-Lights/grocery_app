import 'dart:developer';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetails {
  final String? name;
  final DateTime? expiryDate;
  final DateTime? manufacturingDate;
  final String? rawText;
  final String? barcode;
  final String? brand;
  final String? ingredients;

  ProductDetails({
    this.name,
    this.expiryDate,
    this.manufacturingDate,
    this.rawText,
    this.barcode,
    this.brand,
    this.ingredients,
  });
}

class TextRecognitionService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  Future<ProductDetails> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Run text recognition and barcode scanning in parallel
      final results = await Future.wait([
        textRecognizer.processImage(inputImage),
        barcodeScanner.processImage(inputImage),
      ]);

      final recognizedText = results[0] as RecognizedText;
      final barcodes = results[1] as List<Barcode>;

      String? productName;
      DateTime? expiryDate;
      DateTime? manufacturingDate;
      String? barcode;
      String? brand;
      String? ingredients;

      // Process barcode first
      if (barcodes.isNotEmpty) {
        barcode = barcodes.first.rawValue;
        log('Found barcode: $barcode');

        if (barcode != null) {
          // Try multiple product databases
          final productInfo = await _lookupProduct(barcode);
          if (productInfo != null) {
            productName = productInfo['name'];
            brand = productInfo['brand'];
            ingredients = productInfo['ingredients'];
            log('Found product info from barcode: $productInfo');
          }
        }
      }

      // Process text for dates
      final text = recognizedText.text;
      log('Raw recognized text: $text');

      for (TextBlock block in recognizedText.blocks) {
        final line = block.text.trim();
        log('Processing text block: $line');

        // Look for dates in various formats
        final datePatterns = [
          RegExp(r'(\d{2})[./](\d{2})[./](\d{2,4})'),
          RegExp(r'(\d{2})[-](\d{2})[-](\d{2,4})'),
          RegExp(r'(\d{2})\s+(\d{2})\s+(\d{2,4})'),
        ];

        for (var pattern in datePatterns) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            try {
              int day = int.parse(match.group(1)!);
              int month = int.parse(match.group(2)!);
              int year = int.parse(match.group(3)!);
              
              if (year < 100) year += 2000;
              
              final date = DateTime(year, month, day);
              log('Found date: $date');
              
              // If date is in the future, consider it expiry date
              if (date.isAfter(DateTime.now())) {
                if (expiryDate == null || date.isBefore(expiryDate)) {
                  expiryDate = date;
                  log('Set as expiry date');
                }
              } else {
                if (manufacturingDate == null || date.isAfter(manufacturingDate)) {
                  manufacturingDate = date;
                  log('Set as manufacturing date');
                }
              }
            } catch (e) {
              log('Error parsing date: $e');
            }
          }
        }
      }

      // If no product name from barcode, try to find it in text
      if (productName == null) {
        for (TextBlock block in recognizedText.blocks) {
          final line = block.text.trim();
          if (!_containsDate(line) && 
              !_isCommonLabel(line) &&  
              line.length > 2) {
            productName = _cleanProductName(line);
            log('Found product name from text: $productName');
            break;
          }
        }
      }

      return ProductDetails(
        name: productName,
        expiryDate: expiryDate,
        manufacturingDate: manufacturingDate,
        rawText: text,
        barcode: barcode,
        brand: brand,
        ingredients: ingredients,
      );
    } catch (e) {
      log('Error processing image: $e');
      rethrow;
    } finally {
      textRecognizer.close();
      barcodeScanner.close();
    }
  }

  Future<Map<String, String>?> _lookupProduct(String barcode) async {
    try {
      // Try Open Food Facts API first
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          return {
            'name': product['product_name'] ?? '',
            'brand': product['brands'] ?? '',
            'ingredients': product['ingredients_text'] ?? '',
          };
        }
      }

      // Try UPC Database API as fallback
      final upcResponse = await http.get(
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'),
      );

      if (upcResponse.statusCode == 200) {
        final data = json.decode(upcResponse.body);
        if (data['items']?.isNotEmpty) {
          final item = data['items'][0];
          return {
            'name': item['title'] ?? '',
            'brand': item['brand'] ?? '',
            'ingredients': '', // UPC Database doesn't provide ingredients
          };
        }
      }

      return null;
    } catch (e) {
      log('Error looking up product: $e');
      return null;
    }
  }

  bool _containsDate(String text) {
    return RegExp(r'\d{2}[./-]\d{2}[./-]\d{2,4}').hasMatch(text);
  }

  bool _isCommonLabel(String text) {
    final commonLabels = [
      'CATEGORIA',
      'PREIMBALLATO',
      'CONSERVARE',
      'PESO',
      'ORIGINE',
      'CALIBRO',
      'PREZZO',
      'IMPORTO',
      'INGREDIENTI',
      'VALORI',
      'ENERGIA',
      'GRASSI',
      'CARBOIDRATI',
      'PROTEINE',
      'SALE',
    ];
    
    return commonLabels.any((label) => 
      text.toUpperCase().contains(label) ||
      text.toUpperCase().startsWith(label)
    );
  }

  String _cleanProductName(String name) {
    return name
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp(r'[./:*]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
