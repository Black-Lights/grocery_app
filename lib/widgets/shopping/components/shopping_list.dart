import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/shopping_item.dart';
import '../../../services/shopping_service.dart';
import 'shopping_item_card.dart';
import 'empty_shopping_list.dart';
import '../dialogs/edit_item_dialog.dart';
import '../dialogs/delete_item_dialog.dart';

class ShoppingList extends StatelessWidget {
  final ShoppingService _shoppingService = ShoppingService();

  ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return StreamBuilder<List<ShoppingItem>>(
      stream: _shoppingService.getShoppingList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isTablet ? 64 : 48,
                  color: GroceryColors.error,
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  'Error loading shopping list',
                  style: TextStyle(
                    color: GroceryColors.error,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Trigger a rebuild to retry
                    (context as Element).markNeedsBuild();
                  },
                  child: Text(
                    'Tap to retry',
                    style: TextStyle(
                      color: GroceryColors.teal,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: isTablet ? 48 : 40,
                  height: isTablet ? 48 : 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  'Loading your shopping list...',
                  style: TextStyle(
                    color: GroceryColors.grey400,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const EmptyShoppingList();
        }

        return ListView.builder(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ShoppingItemCard(
                item: item,
                onToggleComplete: (value) async {
                  if (value != null) {
                    try {
                      await _shoppingService.toggleItem(item.id, value);
                      if (value) {
                        Get.snackbar(
                          'Item Completed',
                          '${item.name} marked as completed',
                          backgroundColor: GroceryColors.success,
                          colorText: GroceryColors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                          mainButton: TextButton(
                            onPressed: () async {
                              try {
                                await _shoppingService.toggleItem(item.id, false);
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to undo',
                                  backgroundColor: GroceryColors.error,
                                  colorText: GroceryColors.white,
                                );
                              }
                            },
                            child: Text(
                              'UNDO',
                              style: TextStyle(
                                color: GroceryColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to update item',
                        backgroundColor: GroceryColors.error,
                        colorText: GroceryColors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    }
                  }
                },
                onEdit: () {
                  Get.dialog(
                    EditItemDialog(
                      item: item,
                      onUpdate: (quantity, unit) async {
                        try {
                          await _shoppingService.updateItemQuantity(item.id, quantity);
                          await _shoppingService.updateItemUnit(item.id, unit);
                          Get.snackbar(
                            'Success',
                            'Item updated successfully',
                            backgroundColor: GroceryColors.success,
                            colorText: GroceryColors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to update item',
                            backgroundColor: GroceryColors.error,
                            colorText: GroceryColors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                    ),
                  );
                },
                onDelete: () {
                  Get.dialog(
                    DeleteItemDialog(
                      item: item,
                      onDelete: () async {
                        try {
                          await _shoppingService.deleteItem(item.id);
                          Get.snackbar(
                            'Success',
                            'Item deleted successfully',
                            backgroundColor: GroceryColors.success,
                            colorText: GroceryColors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                            mainButton: TextButton(
                              onPressed: () {
                                // TODO: Implement undo delete functionality
                                Get.snackbar(
                                  'Info',
                                  'Undo feature coming soon',
                                  backgroundColor: GroceryColors.teal,
                                  colorText: GroceryColors.white,
                                );
                              },
                              child: Text(
                                'UNDO',
                                style: TextStyle(
                                  color: GroceryColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to delete item',
                            backgroundColor: GroceryColors.error,
                            colorText: GroceryColors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
