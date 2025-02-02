// lib/widgets/area_detail/dialogs/add_edit_product_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../../constants/food_categories.dart';
import '../../common/category_selector.dart';

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
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController unitController;
  late TextEditingController notesController;
  late TextEditingController categoryController;
  late TextEditingController brandController;
  
  final FirestoreService _firestoreService = Get.find();
  final RxBool isLoading = false.obs;
  final Rx<DateTime> manufacturingDate = DateTime.now().obs;
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: widget.product?.name);
    quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '1',
    );
    unitController = TextEditingController(text: widget.product?.unit ?? 'pcs');
    notesController = TextEditingController(text: widget.product?.notes);
    categoryController = TextEditingController(text: widget.product?.category);
    brandController = TextEditingController(text: widget.product?.brand);
    
    if (widget.product != null) {
      manufacturingDate.value = widget.product!.manufacturingDate;
      expiryDate.value = widget.product!.expiryDate;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    notesController.dispose();
    categoryController.dispose();
    brandController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      final quantity = double.parse(quantityController.text.trim());
      
      if (widget.product != null) {
        await _firestoreService.updateProduct(
          widget.area.id,
          widget.product!.id,
          name: nameController.text.trim(),
          category: categoryController.text.trim(),
          manufacturingDate: manufacturingDate.value,
          expiryDate: expiryDate.value!,
          quantity: quantity,
          unit: unitController.text.trim(),
          notes: notesController.text.trim(),
          brand: brandController.text.trim(),
        );
      } else {
        await _firestoreService.addProduct(
          widget.area.id,
          name: nameController.text.trim(),
          category: categoryController.text.trim(),
          manufacturingDate: manufacturingDate.value,
          expiryDate: expiryDate.value!,
          quantity: quantity,
          unit: unitController.text.trim(),
          notes: notesController.text.trim(),
          brand: brandController.text.trim(),
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
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 24 : 16,
        vertical: widget.isTablet ? 40 : 24,
      ),
      child: Container(
        width: widget.isTablet 
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.9,
        height: widget.isTablet
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: GroceryColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Icon and Name
                      _buildCategoryPreview(),
                      SizedBox(height: 24),
                      
                      // Form Fields
                      TextFormField(
                        controller: nameController,
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
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: brandController,
                        decoration: InputDecoration(
                          labelText: 'Brand (Optional)',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      CategorySelector(
                        controller: categoryController,
                        isTablet: widget.isTablet,
                        onCategorySelected: (category) {
                          setState(() {}); // Refresh category icon
                        },
                      ),
                      SizedBox(height: 16),
                      
                      _buildQuantityAndUnit(),
                      SizedBox(height: 16),
                      
                      _buildDates(),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: notesController,
                        maxLines: widget.isTablet ? 6 : 4,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: widget.isTablet ? 100 : 64),
                            child: Icon(Icons.notes),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildCategoryPreview() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GroceryColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GroceryColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              getCategoryIcon(categoryController.text),
              width: widget.isTablet ? 48 : 40,
              height: widget.isTablet ? 48 : 40,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    color: GroceryColors.grey400,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  categoryController.text.isEmpty 
                      ? 'Select Category' 
                      : categoryController.text,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 18 : 16,
                    fontWeight: FontWeight.w500,
                    color: GroceryColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndUnit() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantity',
              prefixIcon: Icon(Icons.numbers),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: unitController,
            decoration: InputDecoration(
              labelText: 'Unit',
              prefixIcon: Icon(Icons.straighten),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
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
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: GroceryColors.teal,
                          onPrimary: GroceryColors.white,
                          surface: GroceryColors.white,
                          onSurface: GroceryColors.navy,
                        ),
                        dialogBackgroundColor: GroceryColors.white,
                      ),
                      child: child!,
                    );
                  },
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
            child: Text(
              'Cancel',
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: widget.isTablet ? 16 : 14,
              ),
            ),
          ),
          SizedBox(width: 16),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.teal,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 32 : 24,
                vertical: widget.isTablet ? 16 : 12,
              ),
            ),
            child: isLoading.value
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
