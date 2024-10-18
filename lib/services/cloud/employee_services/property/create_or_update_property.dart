// create_or_update_property.dart
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

    // Initialize the controllers with existing property data if available
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
      final propertyType = _propertyTypeController.text;
      final floorNumber = _floorNumberController.text;
      final propertyNumber = _propertyNumberController.text;
      final sizeInSquareMeters = _sizeInSquareMetersController.text;
      final pricePerMonth = _pricePerMonthController.text;
      final description = _descriptionController.text;

      try {
        if (widget.property == null) {
          // Creating a new property
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
          // Updating an existing property
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
        Navigator.of(context).pop(); // Go back after saving
      } on CloudStorageException catch (e) {
        _showErrorDialog(
            context, 'Error', 'Failed to save property: ${e.toString()}');
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
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        title: Text(
            widget.property == null ? 'Create Property' : 'Update Property'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg/accountant_dashboard.jpg', // Add a background image path
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField(
                    controller: _propertyTypeController,
                    labelText: 'Property Type',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter property type' : null,
                  ),
                  _buildTextField(
                    controller: _floorNumberController,
                    labelText: 'Floor Number',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter floor number' : null,
                  ),
                  _buildTextField(
                    controller: _propertyNumberController,
                    labelText: 'Property Number',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter property number' : null,
                  ),
                  _buildTextField(
                    controller: _sizeInSquareMetersController,
                    labelText: 'Size in Square Meters',
                    validator: (value) => value!.isEmpty
                        ? 'Please enter size in square meters'
                        : null,
                  ),
                  _buildTextField(
                    controller: _pricePerMonthController,
                    labelText: 'Price per Month',
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter price per month' : null,
                  ),
                  _buildTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    maxLines: 3,
                  ),
                  SwitchListTile(
                    title: const Text('Is Rented'),
                    value: _isRented,
                    onChanged: (bool value) {
                      setState(() {
                        _isRented = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createOrUpdateProperty,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color.fromARGB(255, 66, 143, 107),
                    ),
                    child: Text(widget.property == null ? 'Create' : 'Update'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
