import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocery/pages/area_detail_page.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';

class AddEditProductDialog extends StatefulWidget {
  final Area area;
  final Product? product;
  final bool isTablet;

  const AddEditProductDialog({
    Key? key,
    required this.area,
    this.product,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _notesController;
  late TextEditingController _categoryController;
  final FirestoreService _firestoreService = FirestoreService();
  final RxBool isLoading = false.obs; // Changed from _isLoading to isLoading
  final Rx<DateTime?> manufacturingDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);
  final RxBool _showCategoryDropdown = false.obs;
  final RxList<String> filteredCategories = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '1',
    );
    _unitController = TextEditingController(text: widget.product?.unit);
    _notesController = TextEditingController(text: widget.product?.notes);
    _categoryController = TextEditingController(text: widget.product?.category);
    manufacturingDate.value = widget.product?.manufacturingDate;
    expiryDate.value = widget.product?.expiryDate;

    // Add listener for category filtering
    _categoryController.addListener(_onCategoryChanged);
  }

  @override
  void dispose() {
    _categoryController.removeListener(_onCategoryChanged);
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _onCategoryChanged() {
    final query = _categoryController.text.toLowerCase();
    if (query.isEmpty) {
      _showCategoryDropdown.value = false;
      filteredCategories.clear();
    } else {
      filteredCategories.value = foodCategories
          .where((category) => 
              category.toLowerCase().contains(query))
          .toList();
      _showCategoryDropdown.value = true;
    }
  }

  void _selectCategory(String category) {
    _categoryController.text = category;
    _showCategoryDropdown.value = false;
    filteredCategories.clear();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true; // Using isLoading here
      
      final quantity = double.parse(_quantityController.text.trim());
      
      if (widget.product != null) {
        await _firestoreService.updateProduct( // Using _firestoreService here
          widget.area.id,
          widget.product!.id,
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          manufacturingDate: manufacturingDate.value!,
          expiryDate: expiryDate.value!,
          quantity: quantity,
          unit: _unitController.text.trim(),
          notes: _notesController.text.trim(),
        );
      } else {
        await _firestoreService.addProduct( // Using _firestoreService here
          widget.area.id,
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          manufacturingDate: manufacturingDate.value!,
          expiryDate: expiryDate.value!,
          quantity: quantity,
          unit: _unitController.text.trim(),
          notes: _notesController.text.trim(),
        );
      }

      Get.back();
      Get.snackbar(
        'Success',
        widget.product != null 
            ? 'Product updated successfully'
            : 'Product added successfully',
        backgroundColor: GroceryColors.success,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        widget.product != null 
            ? 'Failed to update product'
            : 'Failed to add product',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false; // Using isLoading here
    }
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _categoryController,
          decoration: InputDecoration(
            labelText: 'Category',
            hintText: 'Start typing to search categories',
            prefixIcon: Icon(Icons.category_outlined),
            suffixIcon: _categoryController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _categoryController.clear();
                      _showCategoryDropdown.value = false;
                      filteredCategories.clear();
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a category';
            }
            if (!foodCategories.contains(value)) {
              return 'Please select a valid category';
            }
            return null;
          },
        ),
        Obx(() {
          if (!_showCategoryDropdown.value || filteredCategories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: BoxConstraints(
              maxHeight: widget.isTablet ? 200 : 150,
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
                final isSelected = category == _categoryController.text;

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
                          Icon(
                            Icons.category_outlined,
                            size: 20,
                            color: isSelected
                                ? GroceryColors.teal
                                : GroceryColors.grey400,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: widget.isTablet ? 16 : 14,
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


  @override
  Widget build(BuildContext context) {
    final dialogWidth = widget.isTablet 
        ? MediaQuery.of(context).size.width * 0.6 
        : MediaQuery.of(context).size.width * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      SizedBox(height: 20),
                      _buildCategoryField(),
                      SizedBox(height: 20),
                      _buildQuantityAndUnit(),
                      SizedBox(height: 20),
                      _buildDates(),
                      SizedBox(height: 20),
                      _buildNotesField(),
                    ],
                  ),
                ),
              ),

              // Actions
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: GroceryColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.product != null ? Icons.edit : Icons.add,
            color: GroceryColors.teal,
            size: widget.isTablet ? 28 : 24,
          ),
          SizedBox(width: 12),
          Text(
            widget.product != null ? 'Edit Product' : 'Add Product',
            style: TextStyle(
              fontSize: widget.isTablet ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Product Name',
        prefixIcon: Icon(Icons.inventory_2_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a product name';
        }
        return null;
      },
    );
  }

  Widget _buildQuantityAndUnit() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantity',
              prefixIcon: Icon(Icons.numbers),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter quantity';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _unitController,
            decoration: InputDecoration(
              labelText: 'Unit',
              prefixIcon: Icon(Icons.straighten),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter unit';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDates() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            label: 'Manufacturing Date',
            date: manufacturingDate,
            maxDate: DateTime.now(),
            validator: (value) {
              if (value == null) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            label: 'Expiry Date',
            date: expiryDate,
            minDate: DateTime.now(),
            validator: (value) {
              if (value == null) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required Rx<DateTime?> date,
    DateTime? minDate,
    DateTime? maxDate,
    String? Function(DateTime?)? validator,
  }) {
    return FormField<DateTime>(
      initialValue: date.value,
      validator: validator,
      builder: (FormFieldState<DateTime> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: date.value ?? DateTime.now(),
                  firstDate: minDate ?? DateTime(2000),
                  lastDate: maxDate ?? DateTime(2100),
                );
                if (selectedDate != null) {
                  date.value = selectedDate;
                  field.didChange(selectedDate);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: field.hasError 
                        ? GroceryColors.error 
                        : GroceryColors.grey200,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: GroceryColors.grey400,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: GroceryColors.grey400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Obx(() => Text(
                            date.value?.toString().split(' ')[0] ?? 'Select date',
                            style: TextStyle(
                              fontSize: 16,
                              color: date.value == null 
                                  ? GroceryColors.grey300
                                  : GroceryColors.navy,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: GroceryColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: widget.isTablet ? 8 : 5,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: widget.isTablet ? 140 : 84),
          child: Icon(Icons.notes),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: GroceryColors.background,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 24 : 16,
                vertical: widget.isTablet ? 16 : 12,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: widget.isTablet ? 16 : 14,
                color: GroceryColors.grey400,
              ),
            ),
          ),
          SizedBox(width: 12),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : _saveProduct, // Using isLoading here
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.teal,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 32 : 24,
                vertical: widget.isTablet ? 16 : 12,
              ),
            ),
            child: isLoading.value // Using isLoading here
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GroceryColors.white,
                      ),
                    ),
                  )
                : Text(
                    widget.product != null ? 'Update' : 'Add',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
        ],
      ),
    );
  }
}
