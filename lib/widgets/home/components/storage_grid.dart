import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../../config/theme.dart';
import 'storage_card.dart';

class StorageGrid extends ConsumerWidget {
  final bool isEditing;

  const StorageGrid({
    Key? key,
    required this.isEditing,
  }) : super(key: key);

  void _handleEditArea(BuildContext context, Area area) {
    final nameController = TextEditingController(text: area.name);
    final descriptionController = TextEditingController(text: area.description);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
                  
                  await firestoreService.updateArea(updatedArea);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Area updated successfully'),
                      backgroundColor: GroceryColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to update area'),
                      backgroundColor: GroceryColors.error,
                    ),
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

  Widget _buildAddAreaCard(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: GroceryColors.teal.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAddAreaDialog(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: isTablet ? 48 : 40,
              color: GroceryColors.teal,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Add Area',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: GroceryColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAreaDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final isTablet = MediaQuery.of(context).size.width > 600;
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Storage Area',
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
            onPressed: () => Navigator.pop(context),
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
                  await firestoreService.addArea(
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Area added successfully'),
                      backgroundColor: GroceryColors.success,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to add area'),
                      backgroundColor: GroceryColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteArea(BuildContext context, Area area) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              stream: firestoreService.getAreaProducts(area.id),
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
            onPressed: () => Navigator.pop(context),
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
                await firestoreService.deleteArea(area.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Area deleted successfully'),
                    backgroundColor: GroceryColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Failed to delete area'),
                    backgroundColor: GroceryColors.error,
                  ),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Area>>(
      stream: firestoreService.getAreas(),
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
        
        if (areas.isEmpty && !isEditing) {
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
          itemCount: isEditing ? areas.length + 1 : areas.length,
          itemBuilder: (context, index) {
            if (index == areas.length && isEditing) {
              return _buildAddAreaCard(context);
            }
            return StorageCard(
              area: areas[index],
              isEditing: isEditing,
              onEdit: (area) => _handleEditArea(context, area),
              onDelete: (area) => _handleDeleteArea(context, area),
            );
          },
        );
      },
    );
  }
}
