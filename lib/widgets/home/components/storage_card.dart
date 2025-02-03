import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show pi, sin;
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../../config/theme.dart';

class StorageCard extends StatefulWidget {
  final Area area;
  final bool isEditing;
  final Function(Area) onEdit;
  final Function(Area) onDelete;

  const StorageCard({
    Key? key,
    required this.area,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateShakeAnimation();
  }

  @override
  void didUpdateWidget(StorageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateShakeAnimation();
  }

  void _updateShakeAnimation() {
    if (widget.isEditing) {
      _shakeController.repeat();
    } else {
      _shakeController.stop();
      _shakeController.reset();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

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

    Widget card = Hero(
      tag: 'area-${widget.area.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEditing ? null : () => context.push('/area/${widget.area.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 280 : double.infinity,
              maxHeight: isTablet ? 280 : double.infinity,
            ),
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
            child: Stack(
              children: [
                // Main Content
                StreamBuilder<List<Product>>(
                  stream: _firestoreService.getAreaProducts(widget.area.id),
                  builder: (context, snapshot) {
                    final productCount = snapshot.data?.length ?? 0;
                    
                    return Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 16 : 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon Container
                            Container(
                              padding: EdgeInsets.all(isTablet ? 14 : 12),
                              decoration: BoxDecoration(
                                color: GroceryColors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getAreaIcon(widget.area.name),
                                size: isTablet ? 36 : 24,
                                color: GroceryColors.teal,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            
                            // Area Name
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 180 : 150,
                              ),
                              child: Text(
                                widget.area.name,
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: GroceryColors.navy,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Description
                            if (widget.area.description.isNotEmpty) ...[
                              SizedBox(height: isTablet ? 6 : 4),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: isTablet ? 160 : 130,
                                ),
                                child: Text(
                                  widget.area.description,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: GroceryColors.grey400,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            SizedBox(height: isTablet ? 12 : 8),
                            
                            // Product Count Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16 : 12,
                                vertical: isTablet ? 6 : 4,
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
                      ),
                    );
                  },
                ),
                
                // Edit Mode Overlay
                if (widget.isEditing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: GroceryColors.navy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Edit Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: GroceryColors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: GroceryColors.navy.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, color: GroceryColors.teal),
                                onPressed: () => widget.onEdit(widget.area),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ),
                          // Delete Button
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: GroceryColors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: GroceryColors.navy.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.close, color: GroceryColors.error),
                                onPressed: () => widget.onDelete(widget.area),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    // Apply shake animation when in edit mode
    if (widget.isEditing) {
      return AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final sineValue = sin(_shakeController.value * 2 * pi);
          return Transform.rotate(
            angle: sineValue * 0.02, // Adjust this value to control shake intensity
            child: child,
          );
        },
        child: card,
      );
    }

    return card;
  }
}
