import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../services/text_recognition_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../constants/food_categories.dart';

class ProductDetailsDialog extends StatefulWidget {
  final ProductDetails details;
  final String imagePath;
  final String? areaId;
  final String? selectedAreaId;
  final Function(String?) onAreaSelected;
  final FirestoreService firestoreService;
  final bool isTablet;

  const ProductDetailsDialog({
    Key? key,
    required this.details,
    required this.imagePath,
    this.areaId,
    this.selectedAreaId,
    required this.onAreaSelected,
    required this.firestoreService,
    this.isTablet = false,
  }) : super(key: key);

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController unitController;
  late TextEditingController notesController;
  late TextEditingController categoryController;
  late TextEditingController brandController;  // Added brand controller
  String? _selectedAreaId;
  final RxBool isLoading = false.obs;
  final RxBool showCategoryDropdown = false.obs;
  final RxBool showRawText = false.obs;
  final RxList<String> filteredCategories = <String>[].obs;
  final Rx<DateTime?> manufacturingDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    _selectedAreaId = widget.areaId ?? widget.selectedAreaId;
    
    // Initialize with barcode data if available
    if (widget.details.barcode != null) {
      print('Barcode detected: ${widget.details.barcode}');
    }

    nameController = TextEditingController(text: widget.details.name);
    quantityController = TextEditingController(text: '1');
    unitController = TextEditingController(text: 'pcs');
    categoryController = TextEditingController();
    notesController = TextEditingController();
    brandController = TextEditingController(text: widget.details.brand); // Initialize brand
    
    manufacturingDate.value = widget.details.manufacturingDate;
    expiryDate.value = widget.details.expiryDate;

    categoryController.addListener(_onCategoryChanged);
  }

  @override
  void dispose() {
    categoryController.removeListener(_onCategoryChanged);
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    notesController.dispose();
    categoryController.dispose();
    brandController.dispose();  // Dispose brand controller
    super.dispose();
  }

  void _onCategoryChanged() {
    final query = categoryController.text.toLowerCase();
    if (query.isEmpty) {
      showCategoryDropdown.value = false;
      filteredCategories.clear();
    } else {
      filteredCategories.value = foodCategories
          .where((category) => 
              category.toLowerCase().contains(query))
          .toList();
      showCategoryDropdown.value = true;
    }
  }

  void _selectCategory(String category) {
    categoryController.text = category;
    showCategoryDropdown.value = false;
    filteredCategories.clear();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      if (_selectedAreaId == null) {
        throw Exception('Please select a storage area');
      }

      await widget.firestoreService.addProduct(
        _selectedAreaId!,
        name: nameController.text.trim(),
        category: categoryController.text.trim(),
        manufacturingDate: manufacturingDate.value!,
        expiryDate: expiryDate.value!,
        quantity: double.parse(quantityController.text),
        unit: unitController.text.trim(),
        notes: notesController.text.trim(),
        brand: brandController.text.trim(),  // Add brand
        barcode: widget.details.barcode,     // Add barcode
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Product added successfully',
        backgroundColor: GroceryColors.success,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildBarcodeInfo() {
    if (widget.details.barcode == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GroceryColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.qr_code,
              color: GroceryColors.grey400,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'No barcode detected',
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GroceryColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code,
                color: GroceryColors.teal,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Barcode Detected',
                style: TextStyle(
                  color: GroceryColors.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.details.barcode!,
            style: TextStyle(
              color: GroceryColors.grey400,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandField() {
    return TextFormField(
      controller: brandController,
      decoration: InputDecoration(
        labelText: 'Brand (Optional)',
        prefixIcon: Icon(Icons.business),
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
            Icons.add_photo_alternate,
            color: GroceryColors.teal,
            size: widget.isTablet ? 28 : 24,
          ),
          SizedBox(width: 12),
          Text(
            'Add Scanned Product',
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

  Widget _buildImagePreview() {
    return Container(
      height: widget.isTablet ? 300 : 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GroceryColors.skyBlue.withOpacity(0.5)),
        image: DecorationImage(
          image: FileImage(File(widget.imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRawTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Extracted Text',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              showRawText.value 
                  ? Icons.keyboard_arrow_up 
                  : Icons.keyboard_arrow_down,
              color: GroceryColors.grey400,
            ),
            onPressed: () => showRawText.toggle(),
          ),
        ),
        Obx(() => showRawText.value
            ? Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GroceryColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GroceryColors.skyBlue.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  widget.details.rawText ?? 'No text extracted',
                  style: TextStyle(
                    color: GroceryColors.grey400,
                    fontSize: 14,
                  ),
                ),
              )
            : SizedBox.shrink()),
      ],
    );
  }

  Widget _buildAreaSelector() {
    return StreamBuilder<List<Area>>(
      stream: widget.firestoreService.getAreas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: GroceryColors.teal,
            ),
          );
        }

        final areas = snapshot.data!;
        
        // Check if current selectedAreaId exists in areas
        if (_selectedAreaId != null && 
            !areas.any((area) => area.id == _selectedAreaId)) {
          _selectedAreaId = null;  // Reset if not found
        }

        return DropdownButtonFormField<String>(
          value: _selectedAreaId,
          hint: Text('Select Storage Area'),
          decoration: InputDecoration(
            labelText: 'Storage Area',
            prefixIcon: Icon(Icons.storage_outlined),
          ),
          items: areas.map((area) {
            return DropdownMenuItem<String>(
              value: area.id,
              child: Text(area.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAreaId = value;
            });
            widget.onAreaSelected(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a storage area';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: categoryController,
          decoration: InputDecoration(
            labelText: 'Category',
            hintText: 'Start typing to search categories',
            prefixIcon: Icon(Icons.category_outlined),
            suffixIcon: categoryController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      categoryController.clear();
                      showCategoryDropdown.value = false;
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
          if (!showCategoryDropdown.value || filteredCategories.isEmpty) {
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
                final isSelected = category == categoryController.text;

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

  Widget _buildQuantityAndUnit() {
    return Row(
      children: [
        Expanded(
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

  Widget _buildNotesField() {
    return TextFormField(
      controller: notesController,
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
                    'Save Product',
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

  bool _isTabletLayout(BuildContext context) {
    // Check both width and orientation
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    return size.width > 900 || (size.width > 600 && isLandscape);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = _isTabletLayout(context);
    
    // Dialog size calculations
    final dialogWidth = isTablet 
        ? size.width * 0.85  // Wider on tablet
        : size.width * 0.9;
    final dialogHeight = isTablet
        ? size.height * 0.85  // Shorter on tablet to account for keyboard
        : size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 40 : 24,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
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
                child: isTablet
                    ? _buildTabletLayout(dialogWidth, dialogHeight)
                    : _buildMobileLayout(),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(double width, double height) {
    return Row(
      children: [
        // Left Panel (40%) - Image and Barcode
        Container(
          width: width * 0.4,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: GroceryColors.skyBlue.withOpacity(0.5),
              ),
            ),
          ),
          child: Column(
            children: [
              // Image Container (80%)
              Expanded(
                flex: 8,
                child: Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GroceryColors.skyBlue.withOpacity(0.5),
                    ),
                    image: DecorationImage(
                      image: FileImage(File(widget.imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Barcode Container (20%)
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.all(16),
                  child: _buildBarcodeInfo(),
                ),
              ),
            ],
          ),
        ),

        // Right Panel (60%) - Form Fields
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAreaSelector(),
                  SizedBox(height: 16),
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
                  _buildBrandField(),
                  SizedBox(height: 16),
                  _buildCategoryField(),
                  SizedBox(height: 16),
                  _buildQuantityAndUnit(),
                  SizedBox(height: 16),
                  _buildDates(),
                  SizedBox(height: 16),
                  _buildNotesField(),
                  SizedBox(height: 16),
                  _buildRawTextSection(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Container
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GroceryColors.skyBlue.withOpacity(0.5),
              ),
              image: DecorationImage(
                image: FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Barcode Info
          _buildBarcodeInfo(),
          SizedBox(height: 16),
          
          // Form Fields
          _buildAreaSelector(),
          SizedBox(height: 16),
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
          _buildBrandField(),
          SizedBox(height: 16),
          _buildCategoryField(),
          SizedBox(height: 16),
          _buildQuantityAndUnit(),
          SizedBox(height: 16),
          _buildDates(),
          SizedBox(height: 16),
          _buildNotesField(),
          SizedBox(height: 16),
          _buildRawTextSection(),
        ],
      ),
    );
  }
}
