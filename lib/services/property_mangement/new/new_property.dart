//new_property.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import '../../auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import '../../cloud/employee_services/cloud_rent_service.dart';

class NewPropertyView extends StatefulWidget {
  final DatabaseProperty? property;

  const NewPropertyView({Key? key, this.property}) : super(key: key);

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
      _numberOfFloorsController.text = widget.property!.floorNumber;
      _propertyNumberController.text = widget.property!.propertyNumber;
      _sizeController.text = widget.property!.sizeInSquareMeters;
      _priceController.text = widget.property!.pricePerMonth;
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

      if (selectedCompany == null) {
        throw Exception('Please select a company.');
      }

      if (widget.property == null) {
        await _propertyService.createProperty(
          creator: userId,
          companyId: selectedCompany!.id,
          propertyType: _propertyTypeController.text,
          floorNumber: _numberOfFloorsController.text,
          propertyNumber: _propertyNumberController.text,
          sizeInSquareMeters: _sizeController.text,
          pricePerMonth: _priceController.text,
          description: _descriptionController.text,
          isRented: _isRented,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property created successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await _propertyService.updateProperty(
          id: widget.property!.id,
          propertyType: _propertyTypeController.text,
          floorNumber: _numberOfFloorsController.text,
          propertyNumber: _propertyNumberController.text,
          sizeInSquareMeters: _sizeController.text,
          pricePerMonth: _priceController.text,
          description: _descriptionController.text,
          isRented: _isRented,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving property: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.property == null ? 'New Property' : 'Update Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<CloudCompany>(
              value: selectedCompany,
              onChanged: (value) {
                setState(() {
                  selectedCompany = value!;
                });
              },
              items: _companies.map((company) {
                return DropdownMenuItem<CloudCompany>(
                  value: company,
                  child: Text(company.companyName ?? ''),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Company'),
            ),
            TextFormField(
              controller: _propertyTypeController,
              decoration: const InputDecoration(labelText: 'Property Type'),
            ),
            TextFormField(
              controller: _numberOfFloorsController,
              decoration: const InputDecoration(labelText: 'Number of Floors'),
            ),
            TextFormField(
              controller: _propertyNumberController,
              decoration: const InputDecoration(labelText: 'Property Number'),
            ),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(labelText: 'Size (m²)'),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price per Month'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            CheckboxListTile(
              title: const Text('Is Rented'),
              value: _isRented,
              onChanged: (value) {
                setState(() {
                  _isRented = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _saveProperty,
              child: Text(widget.property == null
                  ? 'Create Property'
                  : 'Update Property'),
            ),
          ],
        ),
      ),
    );
  }
}
