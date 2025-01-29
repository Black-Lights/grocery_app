import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../../config/theme.dart';
import 'storage_card.dart';

class StorageGrid extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  StorageGrid({Key? key}) : super(key: key);

  void _handleEditArea(BuildContext context, Area area) {
    final nameController = TextEditingController(text: area.name);
    final descriptionController = TextEditingController(text: area.description);
    final isTablet = MediaQuery.of(context).size.width > 600;

    Get.dialog(
      AlertDialog(
        title: Text(
          'Edit Storage Area',
          style: TextStyle(
            color: GroceryColors.navy,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Area Name',
                hintText: 'e.g., Refrigerator, Freezer',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  final updatedArea = Area(
                    id: area.id,
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    createdAt: area.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  
                  await _firestoreService.updateArea(updatedArea);
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Area updated successfully',
                    backgroundColor: GroceryColors.success,
                    colorText: GroceryColors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to update area',
                    backgroundColor: GroceryColors.error,
                    colorText: GroceryColors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteArea(BuildContext context, Area area) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Area',
          style: TextStyle(
            color: GroceryColors.navy,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${area.name}"?',
              style: TextStyle(
                color: GroceryColors.navy,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getAreaProducts(area.id),
              builder: (context, snapshot) {
                final productCount = snapshot.data?.length ?? 0;
                if (productCount > 0) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GroceryColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: GroceryColors.error,
                          size: isTablet ? 24 : 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This area contains $productCount products that will also be deleted.',
                            style: TextStyle(
                              color: GroceryColors.error,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteArea(area.id);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Area deleted successfully',
                  backgroundColor: GroceryColors.success,
                  colorText: GroceryColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete area',
                  backgroundColor: GroceryColors.error,
                  colorText: GroceryColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.error,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: GroceryColors.white,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return StreamBuilder<List<Area>>(
      stream: _firestoreService.getAreas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading areas',
              style: TextStyle(
                color: GroceryColors.error,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
            ),
          );
        }

        final areas = snapshot.data ?? [];
        
        if (areas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storage,
                  size: isTablet ? 80 : 64,
                  color: GroceryColors.grey300,
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  'No storage areas yet',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    color: GroceryColors.grey400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Text(
                  'Tap the + button to add your first storage area',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: GroceryColors.grey300,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: isTablet ? 24 : 16,
            mainAxisSpacing: isTablet ? 24 : 16,
            childAspectRatio: isTablet ? 1.2 : 1,
          ),
          itemCount: areas.length,
          itemBuilder: (context, index) => StorageCard(
            area: areas[index],
            onEdit: (area) => _handleEditArea(context, area),
            onDelete: (area) => _handleDeleteArea(context, area),
          ),
        );
      },
    );
  }
}
