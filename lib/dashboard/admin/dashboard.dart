import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/enums/menu_action.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/properties_view.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/property_service.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/profile_list.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rent_list.dart';

import '../../services/rent/rent_service_old/rents/create_rent_form.dart';
import '../../services/rent/rent_service_old/rents/rent_list_view.dart';
import '../../services/rent/rent_service_old/profile/new_profile.dart';
import '../../services/rent/rent_service_old/rents/rent_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  Future<bool> showLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // void navigateToCreateRent(BuildContext context,
  //     List<DatabaseProfile> profiles, List<DatabaseProperty> properties) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => CreateRentFormWidget(
  //               profiles: profiles,
  //               properties: properties,
  //             )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (MenuAction action) async {
              if (action == MenuAction.signOut) {
                bool logoutConfirmed = await showLogoutDialog(context);
                if (logoutConfirmed) {
                  await AuthService.firebase().signOut();
                  Navigator.pushReplacementNamed(
                      context, hompageRoute); // Navigate to HomePage route
                }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.signOut,
                  child: Text('Logout'),
                )
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Add Member'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileList()),
                );
              },
            ),
            ListTile(
              title: Text('Rent manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PropertiesView()),
                );
              },
            ),
            // ListTile(
            //   title: Text('Create Rent'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => CreateRentFormWidget()),
            //     );
            //   },
            // ),
            ListTile(
              title: Text('List Rent'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RentList()),
                );
              },
            ),
            ListTile(
              title: Text('new profile '),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewProfile()),
                );
              },
            ),
            // Add more list tiles for other dashboard options
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Admin Dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
