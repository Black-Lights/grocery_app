import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CachedImageService {
  static final Map<String, String> _imageCache = {}; // Memory cache to avoid repeated lookups

  /// Get product image **only from local storage** (do not fetch from internet)
  Future<String?> getCachedProductImage(String barcode) async {
    try {
      // Check in-memory cache first
      if (_imageCache.containsKey(barcode)) {
        return _imageCache[barcode];
      }

      // Get local storage path for cached images
      final cachedImagePath = await _getCachedImagePath(barcode);
      final cachedImageFile = File(cachedImagePath);

      //   If cached image exists, return its local path and store in memory cache
      if (await cachedImageFile.exists()) {
        _imageCache[barcode] = cachedImagePath;
        return cachedImagePath;
      }

      // ❌ No cached image found
      return null;
    } catch (e) {
      log('Error getting cached product image: $e');
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