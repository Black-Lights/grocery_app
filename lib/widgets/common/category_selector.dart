import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
// import 'category_icon.dart'; 
import '../../constants/food_categories.dart';

class CategorySelector extends StatelessWidget {
  final TextEditingController controller;
  final bool isTablet;
  final Function(String) onCategorySelected;

  final RxBool showDropdown = false.obs;
  final RxList<String> filteredCategories = <String>[].obs;
  final RxString selectedCategory = ''.obs;  // Add this to track selected category

  CategorySelector({
    Key? key,
    required this.controller,
    this.isTablet = false,
    required this.onCategorySelected,
  }) : super(key: key) {
    controller.addListener(_onSearchChanged);
    // Initialize selected category if controller has initial value
    selectedCategory.value = controller.text;
  }

  void _onSearchChanged() {
    final query = controller.text.toLowerCase();
    selectedCategory.value = controller.text;  // Update selected category
    
    if (query.isEmpty) {
      filteredCategories.clear();
      showDropdown.value = false;
      return;
    }

    filteredCategories.value = foodCategoryNames
        .where((category) => 
            category.toLowerCase().contains(query))
        .toList();
    showDropdown.value = true;
  }

  void _selectCategory(String category) {
    controller.text = category;
    selectedCategory.value = category;  // Update selected category
    showDropdown.value = false;
    filteredCategories.clear();
    onCategorySelected(category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Category',
            hintText: 'Start typing to search categories',
            // T apply theme icons uncomment this and comment the next same block

            // prefixIcon: selectedCategory.value.isNotEmpty
            //     ? Padding(
            //         padding: EdgeInsets.all(8),
            //         child: CategoryIcon(
            //           iconPath: getCategoryIcon(selectedCategory.value),
            //           isSelected: true,
            //           size: 32,
            //         ),
            //       )
            //     : Icon(Icons.category_outlined),

            prefixIcon: selectedCategory.value.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(8),
                    width: 48,
                    height: 48,
                    child: Image.asset(
                      getCategoryIcon(selectedCategory.value),
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(Icons.category_outlined),
            suffixIcon: selectedCategory.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      selectedCategory.value = '';  // Clear selected category
                      showDropdown.value = false;
                      filteredCategories.clear();
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a category';
            }
            if (!foodCategoryNames.contains(value)) {
              return 'Please select a valid category';
            }
            return null;
          },
        )),
        Obx(() {
          if (!showDropdown.value || filteredCategories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: BoxConstraints(
              maxHeight: isTablet ? 300 : 200,
            ),
            decoration: BoxDecoration(
              color: GroceryColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GroceryColors.skyBlue.withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: GroceryColors.navy.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                final isSelected = category == controller.text;
                final iconPath = getCategoryIcon(category);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GroceryColors.teal.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: index < filteredCategories.length - 1
                              ? BorderSide(
                                  color: GroceryColors.skyBlue.withOpacity(0.5),
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                        // uncomment this for the themed icons
                          // CategoryIcon(
                          //   iconPath: iconPath,
                          //   isSelected: isSelected,
                          //   size: 48,
                          //   isDropdown: true,
                          // ),
                          // Increased Icon Container Size
                          Container(
                            width: 48,  // Increased from 32
                            height: 48, // Increased from 32
                            padding: EdgeInsets.all(6), // Adjusted padding
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24), // Adjusted for new size
                              border: Border.all(
                                color: isSelected
                                    ? GroceryColors.teal
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              iconPath,
                              width: 36, // Increased from 24
                              height: 36, // Increased from 24
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16), // Increased spacing after icon
                          Expanded(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? GroceryColors.teal
                                    : GroceryColors.navy,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              size: 20,
                              color: GroceryColors.teal,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
