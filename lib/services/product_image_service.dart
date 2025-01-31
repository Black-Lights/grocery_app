import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert'; 

class ProductImageService {
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v0/product/';

  Future<Map<String, dynamic>?> getProductInfo(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$openFoodFactsBaseUrl$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          return {
            'name': product['product_name'],
            'brand': product['brands'],
            'imageUrl': product['image_url'],
            'ingredients': product['ingredients_text'],
            'categories': product['categories'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error fetching product info: $e');
      return null;
    }
  }

  Future<String?> getProductImage(String barcode, String? userImagePath) async {
    try {
      // Try to get from OpenFoodFacts first
      final productInfo = await getProductInfo(barcode);
      if (productInfo != null && productInfo['imageUrl'] != null) {
        // Return the URL directly instead of downloading
        return productInfo['imageUrl'];
      }

      // If no OpenFoodFacts image, return user image
      return userImagePath;
    } catch (e) {
      print('Error getting product image: $e');
      return userImagePath;
    }
  }

  Future<String?> downloadAndSaveImage(String barcode, String imageUrl) async {
    try {
      // Get local storage directory
      final appDir = await getApplicationDocumentsDirectory();
      final productImagesDir = Directory('${appDir.path}/product_images');
      
      // Create directory if it doesn't exist
      if (!await productImagesDir.exists()) {
        await productImagesDir.create(recursive: true);
      }

      // Create image file path
      final imagePath = path.join(productImagesDir.path, '$barcode.jpg');
      final imageFile = File(imagePath);

      // Check if image already exists locally
      if (await imageFile.exists()) {
        return imagePath;
      }

      // Download image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await imageFile.writeAsBytes(response.bodyBytes);
        return imagePath;
      }

      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

}
