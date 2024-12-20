import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_storage_exceptions.dart';

class CreateOrUpdateProperty extends StatefulWidget {
  final CloudProperty? property;
  final String creatorId;
  final String companyId;

  const CreateOrUpdateProperty({
    super.key,
    this.property,
    required this.creatorId,
    required this.companyId,
  });

  @override
  State<CreateOrUpdateProperty> createState() => _CreateOrUpdatePropertyState();
}

class _CreateOrUpdatePropertyState extends State<CreateOrUpdateProperty> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _propertyTypeController;
  late TextEditingController _floorNumberController;
  late TextEditingController _propertyNumberController;
  late TextEditingController _sizeInSquareMetersController;
  late TextEditingController _pricePerMonthController;
  late TextEditingController _descriptionController;
  bool _isRented = false;

  @override
  void initState() {
    super.initState();
    _propertyTypeController =
        TextEditingController(text: widget.property?.propertyType ?? '');
    _floorNumberController =
        TextEditingController(text: widget.property?.floorNumber ?? '');
    _propertyNumberController =
        TextEditingController(text: widget.property?.propertyNumber ?? '');
    _sizeInSquareMetersController =
        TextEditingController(text: widget.property?.sizeInSquareMeters ?? '');
    _pricePerMonthController =
        TextEditingController(text: widget.property?.pricePerMonth ?? '');
    _descriptionController =
        TextEditingController(text: widget.property?.description ?? '');
    _isRented = widget.property?.isRented ?? false;
  }

  @override
  void dispose() {
    _propertyTypeController.dispose();
    _floorNumberController.dispose();
    _propertyNumberController.dispose();
    _sizeInSquareMetersController.dispose();
    _pricePerMonthController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createOrUpdateProperty() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final propertyType = _propertyTypeController.text;
        final floorNumber = _floorNumberController.text;
        final propertyNumber = _propertyNumberController.text;
        final sizeInSquareMeters = _sizeInSquareMetersController.text;
        final pricePerMonth = _pricePerMonthController.text;
        final description = _descriptionController.text;

        if (widget.property == null) {
          await PropertyService().createProperty(
            creator: widget.creatorId,
            companyId: widget.companyId,
            propertyType: propertyType,
            floorNumber: floorNumber,
            propertyNumber: propertyNumber,
            sizeInSquareMeters: sizeInSquareMeters,
            pricePerMonth: pricePerMonth,
            description: description,
            isRented: _isRented,
          );
        } else {
          await PropertyService().updateProperty(
            id: widget.property!.id,
            propertyType: propertyType,
            floorNumber: floorNumber,
            propertyNumber: propertyNumber,
            sizeInSquareMeters: sizeInSquareMeters,
            pricePerMonth: pricePerMonth,
            description: description,
            isRented: _isRented,
          );
        }
        if (!mounted) return;
        Navigator.of(context).pop();
      } on CloudStorageException catch (e) {
        _showErrorDialog(context, 'Error', 'Failed to save property: $e');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.property == null ? 'Create Property' : 'Update Property'),
        backgroundColor: const Color(0xFF428F6B),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/accountant_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(
                    alpha: 0.4), // Optional tint for better contrast
              ),
            ),
          ),
          // Form Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField('Property Type', _propertyTypeController),
                  _buildTextField('Floor Number', _floorNumberController),
                  _buildTextField('Property Number', _propertyNumberController),
                  _buildTextField(
                      'Size in Square Meters', _sizeInSquareMetersController),
                  _buildTextField('Price per Month', _pricePerMonthController),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 3),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Is Rented?',
                      style: TextStyle(color: Colors.white),
                    ),
                    activeColor: Colors.lightBlue,
                    value: _isRented,
                    onChanged: (value) {
                      setState(() {
                        _isRented = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Gradient Button
                  ElevatedButton(
                    onPressed: _createOrUpdateProperty,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.lightBlue,
                    ),
                    child: Text(
                      widget.property == null
                          ? 'Create Property'
                          : 'Update Property',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF428F6B), width: 2),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
