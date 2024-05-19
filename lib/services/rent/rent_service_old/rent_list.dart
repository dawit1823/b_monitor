// //rent_list.dart
// import 'package:flutter/material.dart';
// import 'package:r_and_e_monitor/services/rent/create_rent_form.dart';
// import 'package:r_and_e_monitor/services/rent/rent_service_old/rent_service.dart';

// import '../../property_mangement/new/property_service.dart';

// class RentList extends StatefulWidget {
//   const RentList({Key? key}) : super(key: key);
//   @override
//   State<RentList> createState() => _RentListState();
// }

// class _RentListState extends State<RentList> {
//   final RentService _rentService = RentService();
//   final PropertyService _propertyService = PropertyService();
//   List<DatabaseProfile> _profiles = [];
//   List<DatabaseProperty> _properties = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     // Load profiles and properties
//     final profiles = await _rentService.readAllProfiles();
//     final properties = await _propertyService.getAllProperties();
//     setState(() {
//       _profiles = profiles.toList();
//       _properties = properties.toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Rent List'),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CreateRentFormWidget(
//                     profiles: _profiles,
//                     properties: _properties,
//                   ),
//                 ),
//               ).then((_) {
//                 // Refresh data when returning from CreateRentFormWidget
//                 _loadData();
//               });
//             },
//             child: Text('Add a Rent'),
//           ),
//           // Expanded(
//           //   child: ListView.builder(
//           //     itemCount: _profiles.length, // Or use another count
//           //     itemBuilder: (context, index) {
//           //       final profile = _profiles[index];
//           //       return ListTile(
//           //         title: Text(profile.companyName ?? ''),
//           //         // Add other rent details if needed
//           //       );
//           //     },
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
