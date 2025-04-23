import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/area.dart';
import '../../../services/firestore_service.dart';
import '../../../config/theme.dart';


class FormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController manufacturingController;
  final TextEditingController expiryController;
  final TextEditingController notesController;
  final bool isLargeScreen;
  final String? areaId;
  final String? selectedAreaId;
  final Function(String?) onAreaSelected;
  final FirestoreService firestoreService;

  const FormFields({
    Key? key,
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.manufacturingController,
    required this.expiryController,
    required this.notesController,
    required this.isLargeScreen,
    this.areaId,
    this.selectedAreaId,
    required this.onAreaSelected,
    required this.firestoreService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (areaId == null) ...[
          _buildAreaSelector(),
          SizedBox(height: 20),
        ],
        _buildNameField(),
        SizedBox(height: 20),
        _buildQuantityAndUnit(),
        SizedBox(height: 20),
        _buildDates(),
        SizedBox(height: 20),
        _buildNotesField(),
      ],
    );
  }

  Widget _buildAreaSelector() {
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

        return DropdownButtonFormField<String>(
          value: selectedAreaId,
          items: snapshot.data!.map((Area area) {
            return DropdownMenuItem<String>(
              value: area.id,
              child: Text(area.name),
            );
          }).toList(),
          onChanged: onAreaSelected,
          decoration: InputDecoration(
            labelText: 'Storage Area',
            prefixIcon: Icon(Icons.storage_outlined),
          ),
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

  Widget _buildNameField() {
    return TextFormField(
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
            controller: unitController,
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
            controller: manufacturingController,
            maxDate: DateTime.now(),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildDateField(
            label: 'Expiry Date',
            controller: expiryController,
            minDate: DateTime.now(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => controller.clear(),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
      onTap: () async {
        // Get the current context from the build context
        final context = Get.context ?? Get.overlayContext;
        if (context == null) return;

        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
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
        
        if (date != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(date);
        }
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: notesController,
      maxLines: isLargeScreen ? 8 : 5,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: isLargeScreen ? 140 : 84),
          child: Icon(Icons.notes),
        ),
      ),
    );
  }
}
