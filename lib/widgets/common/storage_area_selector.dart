import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/area.dart';
import '../../services/firestore_service.dart';

class StorageAreaSelector extends StatelessWidget {
  final String? initialValue;
  final bool isTablet;
  final Function(String?) onAreaSelected;
  final FirestoreService firestoreService;

  const StorageAreaSelector({
    Key? key,
    this.initialValue,
    this.isTablet = false,
    required this.onAreaSelected,
    required this.firestoreService,
  }) : super(key: key);

  IconData getAreaIcon(String areaName) {
    switch (areaName.toLowerCase()) {
      case 'refrigerator':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.kitchen_outlined;
      case 'cabinet':
        return Icons.door_sliding_outlined;
      case 'counter':
        return Icons.countertops_outlined;
      default:
        return Icons.storage_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Area>>(
      stream: firestoreService.getAreas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: GroceryColors.teal,
            ),
          );
        }

        final areas = snapshot.data!;
        
        String? currentValue = initialValue;
        if (currentValue != null && 
            !areas.any((area) => area.id == currentValue)) {
          currentValue = null;
        }

        // Get the current area for the icon
        final currentArea = currentValue != null 
            ? areas.firstWhere((area) => area.id == currentValue)
            : null;

        return DropdownButtonFormField<String>(
          value: currentValue,
          hint: Text('Select Storage Area'),
          decoration: InputDecoration(
            labelText: 'Storage Area',
            prefixIcon: Icon(
              currentArea != null 
                  ? getAreaIcon(currentArea.name)
                  : Icons.storage_outlined,
            ),
          ),
          selectedItemBuilder: (BuildContext context) {
            return areas.map<Widget>((Area area) {
              return Text(
                area.name,
                style: TextStyle(
                  color: GroceryColors.navy,
                ),
              );
            }).toList();
          },
          items: areas.map((area) {
            return DropdownMenuItem<String>(
              value: area.id,
              child: Row(
                children: [
                  Icon(
                    getAreaIcon(area.name),
                    size: 20,
                    color: GroceryColors.navy,
                  ),
                  SizedBox(width: 12),
                  Text(
                    area.name,
                    style: TextStyle(
                      color: GroceryColors.navy,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            onAreaSelected(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a storage area';
            }
            return null;
          },
          isExpanded: true,
        );
      },
    );
  }
}
