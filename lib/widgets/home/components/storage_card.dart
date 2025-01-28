import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../area_detail_page.dart';

class StorageCard extends StatelessWidget {
  final Area area;
  final FirestoreService _firestoreService = FirestoreService();

  StorageCard({required this.area});

  IconData _getAreaIcon(String areaName) {
    switch (areaName.toLowerCase()) {
      case 'refrigerator':
      case 'fridge':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.kitchen_outlined;
      case 'cabinet':
        return Icons.door_sliding;
      case 'bathroom':
        return Icons.bathroom;
      default:
        return Icons.storage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Hero(
      tag: 'area-${area.id}',
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => Get.to(() => AreaDetailPage(area: area)),
            borderRadius: BorderRadius.circular(16),
            child: StreamBuilder<List<Product>>(
              stream: _firestoreService.getAreaProducts(area.id),
              builder: (context, snapshot) {
                final productCount = snapshot.data?.length ?? 0;
                
                return Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getAreaIcon(area.name),
                        size: isTablet ? 48 : 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        area.name,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (area.description.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          area.description,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$productCount items',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
