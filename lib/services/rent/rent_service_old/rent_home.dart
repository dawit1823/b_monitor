// import 'package:flutter/material.dart';
// import 'package:r_and_e_monitor/services/rent/properties_page.dart';

// import 'package:r_and_e_monitor/services/rent/property_list.dart';
// import 'package:r_and_e_monitor/services/rent/user_profile_page.dart';

// class RentHomePage extends StatelessWidget {
//   const RentHomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Rental App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Welcome to Home Rental App!',
//               style: TextStyle(fontSize: 20.0),
//             ),
//             const SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => PropertyView(),
//                     ));
//               },
//               child: const Text('View Properties'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => PropertyList()),
//                 );
//               },
//               child: const Text('User Profile'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class UserProfilePage extends StatelessWidget {
//   const UserProfilePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//       ),
//       body: const Center(
//         child: Text('User Profile Page'),
//       ),
//     );
//   }
// }
