import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/area.dart';
import '../../../services/firestore_service.dart';

class FormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController manufacturingController;
  final TextEditingController expiryController;
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
        if (areaId == null)
          StreamBuilder<List<Area>>(
            stream: firestoreService.getAreas(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFC857),
                  ),
                );
              }

              return _buildDropdownField(
                value: selectedAreaId,
                items: snapshot.data!.map((Area area) {
                  return DropdownMenuItem<String>(
                    value: area.id,
                    child: Text(area.name),
                  );
                }).toList(),
                onChanged: onAreaSelected,
                label: 'Select Area',
              );
            },
          ),

        if (areaId == null) SizedBox(height: 16),

        _buildTextField(
          controller: nameController,
          label: 'Product Name',
        ),
        SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: quantityController,
                label: 'Quantity',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: unitController,
                label: 'Unit',
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        _buildDateField(
          context: context,
          controller: manufacturingController,
          label: 'Manufacturing Date',
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
        SizedBox(height: 16),

        _buildDateField(
          context: context,
          controller: expiryController,
          label: 'Expiry Date',
          initialDate: DateTime.now().add(Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeScreen ? 16 : 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xFFFFC857),
          fontSize: isLargeScreen ? 16 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4B3F72)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4B3F72)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFFFC857)),
        ),
        filled: true,
        fillColor: Color(0xFF4B3F72).withOpacity(0.7),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required String label,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeScreen ? 16 : 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xFFFFC857),
          fontSize: isLargeScreen ? 16 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4B3F72)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4B3F72)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFFFC857)),
        ),
        filled: true,
        fillColor: Color(0xFF4B3F72).withOpacity(0.7),
      ),
      dropdownColor: Color(0xFF4B3F72),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeScreen ? 16 : 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xFFFFC857),
          fontSize: isLargeScreen ? 16 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4B3F72)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4B3F72)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFFFC857)),
        ),
        filled: true,
        fillColor: Color(0xFF4B3F72).withOpacity(0.7),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Color(0xFFFFC857),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Color(0xFFFFC857),
                  onPrimary: Color(0xFF1F2041),
                  surface: Color(0xFF4B3F72),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: Color(0xFF1F2041),
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
}
