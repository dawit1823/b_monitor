// //property_details_page.dart
// import 'package:flutter/material.dart';
// import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
// import 'package:r_and_e_monitor/dashboard/views/utilities/arguments/get_arguments.dart';

// import '../../cloud/cloud_data_models.dart';
// import '../../cloud/services/cloud_property_service.dart';

// class PropertyDetailsPage extends StatefulWidget {
//   const PropertyDetailsPage({Key? key}) : super(key: key);

//   @override
//   State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
// }

// class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
//   final PropertyService _propertyService = PropertyService();
//   final TextEditingController _propertyTypeController = TextEditingController();
//   final TextEditingController _floorNumberController = TextEditingController();
//   final TextEditingController _propertyNumberController =
//       TextEditingController();
//   final TextEditingController _sizeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   DatabaseProperty? _property;
//   bool _isRented = false;

//   @override
//   void initState() {
//     super.initState();
//     // Moved property assignment to didChangeDependencies
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _property = context.getArgument<DatabaseProperty>();
//     if (_property != null) {
//       _propertyTypeController.text = _property!.propertyType;
//       _floorNumberController.text = _property!.floorNumber;
//       _propertyNumberController.text = _property!.propertyNumber;
//       _sizeController.text = _property!.sizeInSquareMeters;
//       _priceController.text = _property!.pricePerMonth.toString();
//       _descriptionController.text = _property!.description;
//       _isRented = _property!.isRented;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_property?.id != null ? 'Update Property' : 'New Property'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTextField(_propertyTypeController, 'Property Type',
//                 required: true),
//             _buildTextField(_floorNumberController, 'Floor Number',
//                 required: true, isNumeric: true),
//             _buildTextField(_propertyNumberController, 'Property Number',
//                 required: true),
//             _buildTextField(_sizeController, 'Size in Square Meters',
//                 required: true, isNumeric: true),
//             _buildTextField(_priceController, 'Price per Month',
//                 required: true, isNumeric: true),
//             _buildTextField(_descriptionController, 'Description'),
//             SwitchListTile(
//               title: const Text('Is Rented'),
//               value: _isRented,
//               onChanged: (bool value) => setState(() => _isRented = value),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () =>
//                   _property != null ? _updateProperty() : newPropertyRoute,
//               child: Text(_property?.id != null
//                   ? 'Update Property'
//                   : 'Create Property'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label,
//       {bool required = false, bool isNumeric = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(labelText: label),
//         keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
//         validator: (value) {
//           if (required && (value == null || value.isEmpty)) {
//             return 'Please enter $label';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Future _updateProperty() async {
//     if (!_validateInput()) return;

//     try {
//       final property = _property;
//       await _propertyService.updateProperty(
//         id: property!.id,
//         propertyType: _propertyTypeController.text,
//         floorNumber: int.parse(_floorNumberController.text),
//         propertyNumber: _propertyNumberController.text,
//         sizeInSquareMeters: double.parse(_sizeController.text),
//         pricePerMonth: double.parse(_priceController.text),
//         description: _descriptionController.text,
//         isRented: _isRented,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Property updated successfully!'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       Navigator.pop(context); // Close the current page
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error updating property: $error'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   bool _validateInput() {
//     if (_propertyTypeController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter property type')),
//       );
//       return false;
//     }
//     if (_floorNumberController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter floor number')),
//       );
//       return false;
//     }
//     if (_propertyNumberController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter property number')),
//       );
//       return false;
//     }
//     if (_sizeController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter size')),
//       );
//       return false;
//     }
//     if (_priceController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter price')),
//       );
//       return false;
//     }
//     return true;
//   }

//   @override
//   void dispose() {
//     _propertyTypeController.dispose();
//     _floorNumberController.dispose();
//     _propertyNumberController.dispose();
//     _sizeController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }
