import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/enums/menu_action.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/rents/rent_list.dart';
import 'package:r_and_e_monitor/services/cloud/property/property_view.dart';
import '../../services/cloud/company/list_company.dart';
import '../../services/rent/rent_service_old/profile/profile_view.dart'; // Import the listCompany.dart file

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
            const DrawerHeader(
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
              title: const Text('Add Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileView()),
                );
              },
            ),
            ListTile(
              title: const Text('Property View'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PropertyView()),
                );
              },
            ),
            ListTile(
              title: const Text('List Rent'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RentList()),
                );
              },
            ),
            ListTile(
              title: const Text('Companies'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListCompany()),
                );
              },
            ),
            // Add more list tiles for other dashboard options
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Card(
            elevation: 5.0,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: const Center(
              child: Text(
                'Welcome to the Admin Dashboard!',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
