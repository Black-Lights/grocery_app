import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/area.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

final List<String> foodCategories = [
  'Fruits',
  'Vegetables',
  'Dairy',
  'Meat',
  'Poultry',
  'Seafood',
  'Grains',
  'Bread',
  'Pasta',
  'Snacks',
  'Beverages',
  'Condiments',
  'Sauces',
  'Spices',
  'Herbs',
  'Baking Supplies',
  'Canned Goods',
  'Frozen Foods',
  'Ready-to-eat Meals',
  'Breakfast Foods',
  'Desserts',
  'Nuts and Seeds',
  'Oils and Vinegars',
  'Processed Foods',
  'Baby Food',
  'Pet Food',
  'Health Foods',
  'Organic Products',
  'Gluten-free Products',
  'International Foods',
  'Others'
];

class AreaDetailPage extends StatefulWidget {
  final Area area;
  

  const AreaDetailPage({super.key, required this.area});

  @override
  // ignore: library_private_types_in_public_api
  _AreaDetailPageState createState() => _AreaDetailPageState();
}

class _AreaDetailPageState extends State<AreaDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Area currentArea;

  @override
  void initState() {
  super.initState();
  currentArea = widget.area;
  }

    void _showDeleteConfirmation(Product product) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this product?'),
            SizedBox(height: 16),
            Text(
              'Product Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Name: ${product.name}'),
            Text('Category: ${product.category}'),
            Text('Quantity: ${product.quantity} ${product.unit}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteProduct(
                  currentArea.id,
                  product.id,
                );
                Get.back(); // Close dialog
                Get.snackbar(
                  'Success',
                  'Product deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back(); // Close dialog
                Get.snackbar(
                  'Error',
                  'Failed to delete product',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showProductDialog({Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name);
    final quantityController = TextEditingController(
      text: product?.quantity.toString(),
    );
    final unitController = TextEditingController(text: product?.unit);
    final notesController = TextEditingController(text: product?.notes); // Add this line
    
    // Use RxString and RxDateTime for reactive state management
    final RxString selectedCategory = (product?.category ?? '').obs;
    final Rx<DateTime?> manufacturingDate = (product?.manufacturingDate).obs;
    final Rx<DateTime?> expiryDate = (product?.expiryDate).obs;

    // For filtering categories
    final categorySearchController = TextEditingController();
    final RxList<String> filteredCategories = foodCategories.obs;

    final isTablet = MediaQuery.of(Get.context!).size.width > 600;
    final dialogWidth = isTablet 
        ? MediaQuery.of(Get.context!).size.width * 0.6 
        : MediaQuery.of(Get.context!).size.width * 0.9;
    final contentPadding = isTablet ? 24.0 : 16.0;
    final fontSize = isTablet ? 16.0 : 14.0;
    final inputHeight = isTablet ? 60.0 : 48.0;


    void filterCategories(String query) {
      if (query.isEmpty) {
        filteredCategories.value = foodCategories;
      } else {
        filteredCategories.value = foodCategories
            .where((category) => 
                category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      if (!filteredCategories.contains(selectedCategory.value)) {
        selectedCategory.value = '';
      }
    }

    Get.dialog(
      Dialog(
        child: Container(
          width: dialogWidth,
          child: AlertDialog(
            title: Text(
              isEditing ? 'Edit Product' : 'Add Product',
              style: TextStyle(fontSize: isTablet ? 24.0 : 20.0),
            ),
            contentPadding: EdgeInsets.all(contentPadding),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  SizedBox(
                    height: inputHeight,
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(fontSize: fontSize),
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(contentPadding),
                      ),
                    ),
                  ),
                  SizedBox(height: contentPadding),
                  
                  // Category Search
                  SizedBox(
                    height: inputHeight,
                    child: TextField(
                      controller: categorySearchController,
                      style: TextStyle(fontSize: fontSize),
                      decoration: InputDecoration(
                        labelText: 'Search Category',
                        hintText: 'Type to search categories',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.all(contentPadding),
                      ),
                      onChanged: filterCategories,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Category Dropdown
                  Container(
                    height: inputHeight,
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Obx(() {
                      final items = filteredCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: fontSize),
                          ),
                        );
                      }).toList();

                      if (selectedCategory.value.isEmpty) {
                        items.insert(0, DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'Select Category',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ));
                      }

                      return DropdownButton<String>(
                        value: selectedCategory.value.isEmpty ? '' : selectedCategory.value,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: items,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedCategory.value = newValue;
                          }
                        },
                      );
                    }),
                  ),
                  SizedBox(height: contentPadding),
                  
                  // Quantity and Unit
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: quantityController,
                            style: TextStyle(fontSize: fontSize),
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'Enter quantity',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(contentPadding),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      SizedBox(width: contentPadding),
                      Expanded(
                        child: SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: unitController,
                            style: TextStyle(fontSize: fontSize),
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              hintText: 'e.g., kg, pcs',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(contentPadding),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: contentPadding),
                  
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: inputHeight * 1.2,
                          padding: EdgeInsets.all(contentPadding/2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manufacturing Date',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: fontSize * 0.85,
                                ),
                              ),
                              Expanded(
                                child: Obx(() => Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        manufacturingDate.value?.toString().split(' ')[0] ?? 
                                        'Select date',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: manufacturingDate.value == null ? 
                                            Colors.grey : 
                                            Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      onPressed: () async {
                                        final date = await showDatePicker(
                                          context: Get.context!,
                                          initialDate: manufacturingDate.value ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null) {
                                          manufacturingDate.value = date;
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: contentPadding),
                      Expanded(
                        child: Container(
                          height: inputHeight * 1.2,
                          padding: EdgeInsets.all(contentPadding/2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expiry Date',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: fontSize * 0.85,
                                ),
                              ),
                              Expanded(
                                child: Obx(() => Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        expiryDate.value?.toString().split(' ')[0] ?? 
                                        'Select date',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: expiryDate.value == null ? 
                                            Colors.grey : 
                                            Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      onPressed: () async {
                                        final date = await showDatePicker(
                                          context: Get.context!,
                                          initialDate: expiryDate.value ?? 
                                            DateTime.now().add(Duration(days: 30)),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                        );
                                        if (date != null) {
                                          expiryDate.value = date;
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: contentPadding),
                  
                  // Notes
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            'Notes',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: fontSize * 0.85,
                            ),
                          ),
                        ),
                        TextField(
                          controller: notesController,
                          maxLines: isTablet ? 8 : 5,
                          style: TextStyle(fontSize: fontSize),
                          decoration: InputDecoration(
                            hintText: 'Add any additional notes (optional)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(contentPadding),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      selectedCategory.value.isEmpty ||
                      quantityController.text.trim().isEmpty ||
                      unitController.text.trim().isEmpty ||
                      manufacturingDate.value == null ||
                      expiryDate.value == null) {
                    Get.snackbar(
                      'Error',
                      'Please fill all required fields',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    if (isEditing) {
                      await _firestoreService.updateProduct(
                        currentArea.id,
                        product.id,
                        name: nameController.text.trim(),
                        category: selectedCategory.value,
                        manufacturingDate: manufacturingDate.value!,
                        expiryDate: expiryDate.value!,
                        quantity: double.parse(quantityController.text.trim()),
                        unit: unitController.text.trim(),
                        notes: notesController.text.trim(),
                      );
                    } else {
                      await _firestoreService.addProduct(
                        currentArea.id,
                        name: nameController.text.trim(),
                        category: selectedCategory.value,
                        manufacturingDate: manufacturingDate.value!,
                        expiryDate: expiryDate.value!,
                        quantity: double.parse(quantityController.text.trim()),
                        unit: unitController.text.trim(),
                        notes: notesController.text.trim(),
                      );
                    }
                    Get.back();
                    Get.snackbar(
                      'Success',
                      isEditing ? 'Product updated successfully' : 'Product added successfully',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      isEditing ? 'Failed to update product' : 'Failed to add product',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
     // Dispose controllers when dialog is closed
    Get.delete<TextEditingController>(tag: 'notes');
  }


  Widget _buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _firestoreService.getAreaProducts(currentArea.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading products'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No products in ${currentArea.name}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first product',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Category: ${product.category}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Quantity: ${product.quantity} ${product.unit}'),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Expires: ${product.expiryDate.toString().split(' ')[0]}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showProductDialog(product: product),
                        tooltip: 'Edit Product',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteConfirmation(product),
                        tooltip: 'Delete Product',
                      ),
                    ],
                  ),
                ),
                // Show notes in an expanded section if they exist
                if (product.notes?.isNotEmpty ?? false)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Notes:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.notes!,
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildAreasList() {
    return StreamBuilder<List<Area>>(
      stream: _firestoreService.getAreas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading areas'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final areas = snapshot.data ?? [];

        return ListView.builder(
          itemCount: areas.length,
          itemBuilder: (context, index) {
            final area = areas[index];
            final isSelected = area.id == currentArea.id;
            
            return ListTile(
              selected: isSelected,
              tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
              leading: Icon(
                _getAreaIcon(area.name),
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
              title: Text(
                area.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              subtitle: Text(area.description),
              onTap: () {
                if (!isSelected) {
                  final size = MediaQuery.of(context).size;
                  final isTablet = size.width > 600;

                  if (isTablet) {
                    // For tablet, just update the current area
                    setState(() {
                      currentArea = area;
                    });
                  } else {
                    // For mobile, navigate to new page
                    Get.off(
                      () => AreaDetailPage(area: area),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 300),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(currentArea.name), // Use currentArea instead of currentArea
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showProductDialog(),
              tooltip: 'Add Product',
            ),
            SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            // Areas List (Left Side)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Text(
                      'Storage Areas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildAreasList(),
                  ),
                ],
              ),
            ),
            // Products List (Right Side)
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Icon(_getAreaIcon(currentArea.name)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentArea.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (currentArea.description.isNotEmpty)
                                Text(
                                  currentArea.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildProductList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showProductDialog(),
          child: Icon(Icons.add),
          tooltip: 'Add Product',
        ),
      );
    }

    // Mobile layout remains the same
    return Scaffold(
      appBar: AppBar(
        title: Text(currentArea.name),
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}