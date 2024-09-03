// create_or_update_properties.dart
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
      body: _isLoading
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
                    decoration: const InputDecoration(
                      labelText: 'Company',
                    ),
                  ),
                  TextField(
                    controller: _propertyTypeController,
                    decoration:
                        const InputDecoration(labelText: 'Property Type'),
                  ),
                  TextField(
                    controller: _numberOfFloorsController,
                    decoration:
                        const InputDecoration(labelText: 'Number of Floors'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _propertyNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Property Number'),
                  ),
                  TextField(
                    controller: _sizeController,
                    decoration: const InputDecoration(labelText: 'Size (sqm)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _priceController,
                    decoration:
                        const InputDecoration(labelText: 'Price per Month'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
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
                    child: Text(widget.property != null
                        ? 'Update Property'
                        : 'Create Property'),
                  ),
                ],
              ),
            ),
    );
  }
}
