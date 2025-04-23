import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../services/firestore_service.dart';

class AreaSelectionHeader extends StatelessWidget {
  final Area currentArea;
  final Function(Area) onAreaSelected;
  final FirestoreService _firestoreService = FirestoreService();

  AreaSelectionHeader({
    Key? key,
    required this.currentArea,
    required this.onAreaSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // Reduced height
      decoration: BoxDecoration(
        color: GroceryColors.white,
        border: Border(
          bottom: BorderSide(
            color: GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: StreamBuilder<List<Area>>(
        stream: _firestoreService.getAreas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final areas = [
            Area(
              id: 'all',
              name: 'All Items',
              description: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            ...snapshot.data!,
          ];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: areas.length,
            itemBuilder: (context, index) {
              final area = areas[index];
              final isSelected = area.id == currentArea.id;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onAreaSelected(area),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GroceryColors.teal.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? GroceryColors.teal
                            : GroceryColors.skyBlue.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      area.id == 'all' ? 'All Items' : area.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? GroceryColors.teal
                            : GroceryColors.navy,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
