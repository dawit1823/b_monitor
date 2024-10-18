import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import '../../auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import '../../cloud/employee_services/cloud_rent_service.dart';

class NewPropertyView extends StatefulWidget {
  final CloudProperty? property;

  const NewPropertyView({super.key, this.property});

  @override
  State<NewPropertyView> createState() => _NewPropertyViewState();
}

class _NewPropertyViewState extends State<NewPropertyView> {
  late final PropertyService _propertyService;
  late final RentService _rentService;
  late final TextEditingController _propertyTypeController;
  late final TextEditingController _numberOfFloorsController;
  late final TextEditingController _propertyNumberController;
  late final TextEditingController _sizeController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _isRented = false;
  CloudCompany? selectedCompany;
  List<CloudCompany> _companies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _propertyService = PropertyService();
    _rentService = RentService();
    _propertyTypeController = TextEditingController();
    _numberOfFloorsController = TextEditingController();
    _propertyNumberController = TextEditingController();
    _sizeController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchCompanies();

    if (widget.property != null) {
      _propertyTypeController.text = widget.property!.propertyType;
      _numberOfFloorsController.text = widget.property!.floorNumber.toString();
      _propertyNumberController.text = widget.property!.propertyNumber;
      _sizeController.text = widget.property!.sizeInSquareMeters.toString();
      _priceController.text = widget.property!.pricePerMonth.toString();
      _descriptionController.text = widget.property!.description;
      _isRented = widget.property!.isRented;
    }
  }

  Future<void> _fetchCompanies() async {
    try {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      final companies =
          await _rentService.getCompaniesByCreatorId(creatorId: userId);
      setState(() {
        _companies = companies;
        selectedCompany = widget.property != null
            ? companies.firstWhere(
                (company) => company.id == widget.property!.companyId)
            : (companies.isNotEmpty ? companies.first : null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching companies: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _propertyTypeController.dispose();
    _numberOfFloorsController.dispose();
    _propertyNumberController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    try {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;

      final propertyType = _propertyTypeController.text;
      final numberOfFloors = int.parse(_numberOfFloorsController.text);
      final propertyNumber = _propertyNumberController.text;
      final sizeInSquareMeters = double.parse(_sizeController.text);
      final pricePerMonth = double.parse(_priceController.text);
      final description = _descriptionController.text;
      final companyId = selectedCompany?.id ?? '';

      if (widget.property != null) {
        // Updating an existing property
        await _propertyService.updateProperty(
          id: widget.property!.id,
          propertyType: propertyType,
          floorNumber: numberOfFloors.toString(),
          propertyNumber: propertyNumber,
          sizeInSquareMeters: sizeInSquareMeters.toString(),
          pricePerMonth: pricePerMonth.toString(),
          description: description,
          isRented: _isRented,
        );
      } else {
        // Creating a new property
        await _propertyService.createProperty(
          creator: userId,
          propertyType: propertyType,
          floorNumber: numberOfFloors.toString(),
          propertyNumber: propertyNumber,
          sizeInSquareMeters: sizeInSquareMeters.toString(),
          pricePerMonth: pricePerMonth.toString(),
          description: description,
          isRented: _isRented,
          companyId: companyId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving property: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.property != null ? 'Update Property' : 'New Property'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProperty,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg/background_dashboard.jpg'), // Add your background image here
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    DropdownButtonFormField<CloudCompany>(
                      value: selectedCompany,
                      onChanged: (CloudCompany? newCompany) {
                        setState(() {
                          selectedCompany = newCompany;
                        });
                      },
                      items: _companies
                          .map((company) => DropdownMenuItem(
                                value: company,
                                child: Text(company.companyName),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Company',
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_propertyTypeController, 'Property Type'),
                    const SizedBox(height: 10),
                    _buildTextField(_numberOfFloorsController, 'Floor Number',
                        isNumeric: true),
                    const SizedBox(height: 10),
                    _buildTextField(
                        _propertyNumberController, 'Property Number'),
                    const SizedBox(height: 10),
                    _buildTextField(_sizeController, 'Area (sqm)',
                        isNumeric: true),
                    const SizedBox(height: 10),
                    _buildTextField(_priceController, 'Price per Month',
                        isNumeric: true),
                    const SizedBox(height: 10),
                    _buildTextField(_descriptionController, 'Description',
                        maxLines: 3),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Is Rented'),
                      value: _isRented,
                      onChanged: (bool value) {
                        setState(() => _isRented = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProperty,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(widget.property != null
                          ? 'Update Property'
                          : 'Create Property'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Helper method to build text fields with consistent styling
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
    );
  }
}
