import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class ProductImageService {
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v0/product/';

  /// **Fetch product info from OpenFoodFacts API**
  Future<Map<String, dynamic>?> getProductInfo(String barcode) async {
    try {
      final response = await http.get(Uri.parse('$openFoodFactsBaseUrl$barcode.json'));

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

  /// **Get product image from local storage or fetch and save if not cached**
  Future<String?> getProductImage(String barcode, String? userImagePath) async {
    try {
      // Get local storage path for cached images
      final cachedImagePath = await _getCachedImagePath(barcode);
      final cachedImageFile = File(cachedImagePath);

      // ✅ If cached image exists, return its local path
      if (await cachedImageFile.exists()) {
        print('Using cached image: $cachedImagePath');
        return cachedImagePath;
      }

      // Try fetching image from OpenFoodFacts
      final productInfo = await getProductInfo(barcode);
      final imageUrl = productInfo?['imageUrl'];

      // ✅ If OpenFoodFacts provides an image, download and save it locally
      if (imageUrl != null) {
        return await downloadAndSaveImage(barcode, imageUrl);
      }

      // ✅ If no OpenFoodFacts image, return user-uploaded image
      return userImagePath;
    } catch (e) {
      print('Error getting product image: $e');
      return userImagePath;
    }
  }

  /// **Download and cache the product image**
  Future<String?> downloadAndSaveImage(String barcode, String imageUrl) async {
    try {
      // Get local storage directory
      final imagePath = await _getCachedImagePath(barcode);
      final imageFile = File(imagePath);

      // If image already exists locally, return it
      if (await imageFile.exists()) {
        return imagePath;
      }

      // Download image from URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await imageFile.writeAsBytes(response.bodyBytes);
        print('Downloaded and saved image: $imagePath');
        return imagePath;
      }

      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// **Get the file path for a cached image**
  Future<String> _getCachedImagePath(String barcode) async {
    final appDir = await getApplicationDocumentsDirectory();
    final productImagesDir = Directory('${appDir.path}/product_images');

    // Create directory if it doesn't exist
    if (!await productImagesDir.exists()) {
      await productImagesDir.create(recursive: true);
    }

    return path.join(productImagesDir.path, '$barcode.jpg');
  }
}
