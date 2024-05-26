// //properties_view.dart
// import 'package:flutter/material.dart';
// import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
// import 'package:r_and_e_monitor/services/auth/auth_service.dart';
// import 'package:r_and_e_monitor/services/property_mangement/new/new_property.dart';
// import 'package:r_and_e_monitor/services/property_mangement/new/property_service.dart';

// typedef PropertyCallBack = void Function(DatabaseProperty property);

// class PropertiesView extends StatefulWidget {
//   const PropertiesView({Key? key}) : super(key: key);

//   @override
//   State<PropertiesView> createState() => _PropertiesViewState();
// }

// class _PropertiesViewState extends State<PropertiesView> {
//   late final PropertyService _propertyService;
//   String get userEmail => AuthService.firebase().currentUser!.email;

//   @override
//   void initState() {
//     super.initState();
//     _propertyService = PropertyService();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Properties')),
//       body: FutureBuilder(
//         future: _propertyService.getOrCreateUser(email: userEmail),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               return StreamBuilder<List<DatabaseProperty>>(
//                 stream: _propertyService.propertyStream,
//                 builder: (context, snapshot) {
//                   switch (snapshot.connectionState) {
//                     case ConnectionState.waiting:
//                     case ConnectionState.active:
//                       if (snapshot.hasData) {
//                         final propertyStream =
//                             snapshot.data as List<DatabaseProperty>;
//                         final groupedProperties =
//                             _groupProperties(propertyStream);

//                         return ListView.builder(
//                           itemCount: groupedProperties.length,
//                           itemBuilder: (context, index) {
//                             final propertyType =
//                                 groupedProperties.keys.elementAt(index);
//                             final propertiesByType =
//                                 groupedProperties[propertyType]!;

//                             return _buildPropertyGroup(
//                                 propertyType, propertiesByType);
//                           },
//                         );
//                       } else {
//                         return Center(child: CircularProgressIndicator());
//                       }
//                     default:
//                       return Center(child: CircularProgressIndicator());
//                   }
//                 },
//               );
//             default:
//               return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final newProperty = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const NewPropertyView()),
//           );
//           if (newProperty != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Property created successfully'),
//               ),
//             );
//           }
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildPropertyGroup(
//       String propertyType, List<DatabaseProperty> properties) {
//     return ExpansionTile(
//       title: Text(propertyType),
//       children: properties.map((property) {
//         return ListTile(
//           title: Text(
//               'Floor ${property.floorNumber}     office No ${property.propertyNumber}'),
//           onTap: () async {
//             await Navigator.of(context).pushNamed(
//               propertyDetailsPageRoute,
//               arguments: property,
//             );
//           },
//           onLongPress: () {
//             _showDeleteConfirmationDialog(context, property);
//           },
//         );
//       }).toList(),
//     );
//   }

//   Map<String, List<DatabaseProperty>> _groupProperties(
//       List<DatabaseProperty> properties) {
//     final Map<String, List<DatabaseProperty>> groupedProperties = {};

//     for (final property in properties) {
//       if (!groupedProperties.containsKey(property.propertyType)) {
//         groupedProperties[property.propertyType] = [];
//       }
//       groupedProperties[property.propertyType]!.add(property);
//     }

//     return groupedProperties;
//   }

//   Future<void> _showDeleteConfirmationDialog(
//       BuildContext context, DatabaseProperty property) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Deletion'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Are you sure you want to delete this property?'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text(
//                 'Delete',
//                 style: TextStyle(color: Colors.red),
//               ),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 try {
//                   await _propertyService.deleteProperty(id: property.id);
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error deleting property: $e'),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
