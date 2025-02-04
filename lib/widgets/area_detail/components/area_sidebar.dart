import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../services/firestore_service.dart';

class AreaSidebar extends StatelessWidget {
  final Area currentArea;
  final Function(Area) onAreaSelected;
  final bool isTablet;

  const AreaSidebar({
    Key? key,
    required this.currentArea,
    required this.onAreaSelected,
    required this.isTablet,
  }) : super(key: key);

  IconData _getAreaIcon(String areaName) {
    switch (areaName.toLowerCase()) {
      case 'refrigerator':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.kitchen_outlined;
      case 'cabinet':
        return Icons.door_sliding;
      case 'counter':
        return Icons.countertops;
      default:
        return Icons.storage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isTablet ? 300 : 70,
      decoration: BoxDecoration(
        color: GroceryColors.white,
        border: Border(
          right: BorderSide(
            color: GroceryColors.skyBlue.withOpacity(0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isTablet)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GroceryColors.background,
                border: Border(
                  bottom: BorderSide(
                    color: GroceryColors.skyBlue.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storage,
                    color: GroceryColors.navy,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Storage Areas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: GroceryColors.navy,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: StreamBuilder<List<Area>>(
              stream: FirestoreService().getAreas(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading areas',
                      style: TextStyle(
                        color: GroceryColors.error,
                        fontSize: 14,
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

                final allArea = Area(
                  id: 'all',
                  name: 'All Items',
                  description: 'View all products',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final areas = [allArea, ...snapshot.data ?? []];

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final area = areas[index];
                    final isSelected = area.id == currentArea.id;
                    final isAllItems = area.id == 'all';
                    
                    return Material(
                      color: Colors.transparent,
                      child: ListTile(
                        selected: isSelected,
                        selectedTileColor: GroceryColors.teal.withOpacity(0.1),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? GroceryColors.teal.withOpacity(0.1)
                                : GroceryColors.skyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isAllItems ? Icons.all_inbox : _getAreaIcon(area.name),
                            color: isSelected
                                ? GroceryColors.teal
                                : GroceryColors.navy,
                            size: 20,
                          ),
                        ),
                        title: isTablet
                            ? Text(
                                area.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? GroceryColors.teal
                                      : GroceryColors.navy,
                                ),
                              )
                            : null,
                        subtitle: isTablet && area.description.isNotEmpty
                            ? Text(
                                area.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: GroceryColors.grey400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => onAreaSelected(area),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
