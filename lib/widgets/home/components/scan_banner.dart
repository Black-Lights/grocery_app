import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../product_image_capture/product_image_capture.dart';

class ScanBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        child: InkWell(
          onTap: () => Get.to(() => ProductImageCapture()),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.document_scanner,
                  size: isTablet ? 48 : 40,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: isTablet ? 24 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan your Item',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scan your item to add to shopping list or storage area',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: isTablet ? 24 : 20,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
