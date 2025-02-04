import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class ProductImageService {
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v0/product/';
  static final Map<String, DateTime> _lastRequestTimes = {};
  static const Duration requestCooldown = Duration(seconds: 3); // Adds a delay between requests
  // Store cached image paths in memory
  static final Map<String, String> _imageCache = {};

  /// Fetch product info from OpenFoodFacts API
  Future<Map<String, dynamic>?> getProductInfo(String barcode) async {
    try {
      // Check last request time to avoid excessive requests
      if (_lastRequestTimes.containsKey(barcode)) {
        final lastRequestTime = _lastRequestTimes[barcode]!;
        final timeSinceLastRequest = DateTime.now().difference(lastRequestTime);
        if (timeSinceLastRequest < requestCooldown) {
          await Future.delayed(requestCooldown - timeSinceLastRequest);
        }
      }

      final response = await http.get(Uri.parse('$openFoodFactsBaseUrl$barcode.json'));

      _lastRequestTimes[barcode] = DateTime.now(); // Update last request time

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
      log('Error fetching product info: $e');
      return null;
    }
  }

  
  Future<String?> getProductImage(String barcode, String? userImagePath) async {
    try {
      // Check in-memory cache first to avoid redundant disk access
      if (_imageCache.containsKey(barcode)) {
        return _imageCache[barcode];
      }

      // Get local storage path for cached images
      final cachedImagePath = await _getCachedImagePath(barcode);
      final cachedImageFile = File(cachedImagePath);

      // ✅ If cached image exists, return its local path & store it in memory
      if (await cachedImageFile.exists()) {
        _imageCache[barcode] = cachedImagePath;  // Store in memory
        if (!_lastRequestTimes.containsKey(barcode)) {
          log('Using cached image: $cachedImagePath'); // Log only once per session
        }
        return cachedImagePath;
      }

      // Try fetching image from OpenFoodFacts
      final productInfo = await getProductInfo(barcode);
      final imageUrl = productInfo?['imageUrl'];

      // ✅ If OpenFoodFacts provides an image, download and save it locally
      if (imageUrl != null) {
        final downloadedImagePath = await downloadAndSaveImage(barcode, imageUrl);
        if (downloadedImagePath != null) {
          _imageCache[barcode] = downloadedImagePath;
        }
        return downloadedImagePath;
      }

      // ✅ If no OpenFoodFacts image, return user-uploaded image
      return userImagePath;
    } catch (e) {
      log('Error getting product image: $e');
      return userImagePath;
    }
  }

  /// Download and cache the product image
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
        log('Downloaded and saved image: $imagePath');
        return imagePath;
      }

      return null;
    } catch (e) {
      log('Error downloading image: $e');
      return null;
    }
  }

  /// Get the file path for a cached image
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
