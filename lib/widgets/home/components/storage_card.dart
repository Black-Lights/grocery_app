import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../../pages/area_detail_page.dart';
import '../../../config/theme.dart';

class StorageCard extends StatelessWidget {
  final Area area;
  final Function(Area) onEdit;
  final Function(Area) onDelete;
  final FirestoreService _firestoreService = FirestoreService();

  StorageCard({
    Key? key,
    required this.area,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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

  void _showOptionsModal(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: GroceryColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              area.name,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: GroceryColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              area.description.isEmpty ? 'No description' : area.description,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: GroceryColors.grey400,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GroceryColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: GroceryColors.teal,
                  size: isTablet ? 28 : 24,
                ),
              ),
              title: Text(
                'Edit Area',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w500,
                  color: GroceryColors.navy,
                ),
              ),
              subtitle: Text(
                'Modify name and description',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: GroceryColors.grey400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit(area);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GroceryColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: GroceryColors.error,
                  size: isTablet ? 28 : 24,
                ),
              ),
              title: Text(
                'Delete Area',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w500,
                  color: GroceryColors.error,
                ),
              ),
              subtitle: Text(
                'Remove this storage area',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: GroceryColors.grey400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete(area);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Hero(
      tag: 'area-${area.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => AreaDetailPage(area: area)),
          onLongPress: () => _showOptionsModal(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: GroceryColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GroceryColors.skyBlue.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: GroceryColors.navy.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<List<Product>>(
              stream: _firestoreService.getAreaProducts(area.id),
              builder: (context, snapshot) {
                final productCount = snapshot.data?.length ?? 0;
                
                return Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GroceryColors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getAreaIcon(area.name),
                          size: isTablet ? 32 : 24,
                          color: GroceryColors.teal,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      Text(
                        area.name,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: GroceryColors.navy,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (area.description.isNotEmpty) ...[
                        SizedBox(height: isTablet ? 8 : 4),
                        Text(
                          area.description,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: GroceryColors.grey400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: isTablet ? 16 : 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 16 : 12,
                          vertical: isTablet ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: GroceryColors.skyBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: GroceryColors.skyBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          '$productCount items',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w500,
                            color: GroceryColors.teal,
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
