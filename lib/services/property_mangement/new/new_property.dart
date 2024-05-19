// new_property.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/property_service.dart';
import '../../auth/auth_service.dart';

class NewPropertyView extends StatefulWidget {
  const NewPropertyView({Key? key}) : super(key: key);

  @override
  State<NewPropertyView> createState() => _NewPropertyViewState();
}

class _NewPropertyViewState extends State<NewPropertyView> {
  late final PropertyService _propertyService;
  late final TextEditingController _propertyTypeController;
  late final TextEditingController _numberOfFloorsController;
  late final TextEditingController _propertyNumberController;
  late final TextEditingController _sizeController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _isRented = false;

  @override
  void initState() {
    super.initState();
    _propertyService = PropertyService();
    _propertyTypeController = TextEditingController();
    _numberOfFloorsController = TextEditingController();
    _propertyNumberController = TextEditingController();
    _sizeController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Property'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _propertyTypeController,
              decoration: InputDecoration(labelText: 'Property Type'),
            ),
            TextFormField(
              controller: _numberOfFloorsController,
              decoration: InputDecoration(labelText: 'Number of Floors'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _propertyNumberController,
              decoration: InputDecoration(labelText: 'Property Number'),
            ),
            TextFormField(
              controller: _sizeController,
              decoration: InputDecoration(labelText: 'Size (m²)'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price per Month'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            CheckboxListTile(
              title: Text('Is Rented'),
              value: _isRented,
              onChanged: (value) {
                setState(() {
                  _isRented = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _createNewProperty();
              },
              child: Text('Create Property'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewProperty() async {
    try {
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email!;

      print('Creator Email: $email');

      final creator = await _propertyService.createUser(email: email);
      print('Creator: $creator');

      await _propertyService.createProperty(
        creator: creator,
        propertyType: _propertyTypeController.text,
        floorNumber: int.parse(_numberOfFloorsController.text),
        propertyNumber: _propertyNumberController.text,
        sizeInSquareMeters: double.parse(_sizeController.text),
        pricePerMonth: double.parse(_priceController.text),
        description: _descriptionController.text,
        isRented: _isRented,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property created successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating property: $e'),
        ),
      );
    }
  }
}
