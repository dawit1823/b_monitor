// import 'package:flutter/material.dart';
// import 'package:r_and_e_monitor/services/auth/auth_service.dart';
// import 'package:r_and_e_monitor/services/cloud/cloud_rent_service.dart';
// import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
// import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/create_or_update_rents.dart';
// import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/error_dialogs.dart';

// import '../../../../dashboard/views/utilities/arguments/error_dialog.dart';

// class RentListView extends StatefulWidget {
//   const RentListView({Key? key}) : super(key: key);

//   @override
//   State<RentListView> createState() => _RentListViewState();
// }

// class _RentListViewState extends State<RentListView> {
//   late final RentService _rentService;
//   late final List<CloudProfile> _profiles;
//   late final List<DatabaseProperty> _properties;

//   String get userId => AuthService.firebase().currentUser!.id;

//   @override
//   void initState() {
//     _rentService = RentService();
//     _fetchProfilesAndProperties();
//     super.initState();
//   }

//   Future<void> _fetchProfilesAndProperties() async {
//     try {
//       final profiles = await _rentService.fetchProfiles();
//       final properties = await _rentService.fetchProperties();
//       setState(() {
//         _profiles = profiles;
//         _properties = properties;
//       });
//     } catch (e) {
//       showErrorDialog(context, 'Error fetching profiles and properties: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rent List'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               if (_profiles.isNotEmpty && _properties.isNotEmpty) {
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => CreateOrUpdateRentView(
//                     profiles: _profiles,
//                     properties: _properties,
//                   ),
//                 ));
//               } else {
//                 showErrorDialog(context, 'Profiles and properties are not loaded yet.');
//               }
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: _rentService.allRents(creatorId: userId),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//             case ConnectionState.active:
//               if (snapshot.hasData) {
//                 final allRents = snapshot.data as Iterable<CloudRent>;
//                 return ListView.builder(
//                   itemCount: allRents.length,
//                   itemBuilder: (context, index) {
//                     final rent = allRents.elementAt(index);
//                     return ListTile(
//                       title: Text(rent.contract),
//                       subtitle: Text('Due: ${rent.dueDate}'),
//                       onTap: () {
//                         if (_profiles.isNotEmpty && _properties.isNotEmpty) {
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => CreateOrUpdateRentView(
//                               rent: rent,
//                               profiles: _profiles,
//                               properties: _properties,
//                             ),
//                           ));
//                         } else {
//                           showErrorDialog(context, 'Profiles and properties are not loaded yet.');
//                         }
//                       },
//                       trailing: IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () async {
//                           final shouldDelete = await showDeleteDialog(context);
//                           if (shouldDelete) {
//                             await _rentService.deleteRent(id: rent.id);
//                           }
//                         },
//                       ),
//                     );
//                   },
//                 );
//               } else {
//                 return const Center(child: CircularProgressIndicator());
//               }
//             default:
//               return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
