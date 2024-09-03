//accountant_dashboard.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/employee/service/financial_management/list_financial_management.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/profile/list_profile_employee.dart';

class AccountantDashboard extends StatelessWidget {
  final CloudEmployee employee;

  const AccountantDashboard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${employee.name} - Accountant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool logoutConfirmed = await _showLogoutDialog(context);

              if (logoutConfirmed) {
                await AuthService.firebase().signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, landingPageRoute);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('$employee.name'),
              accountEmail: Text('$employee.email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  employee.name[0],
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            _buildDrawerItem(
              context: context,
              title: 'Profile List',
              destination: ListProfileEmployee(
                creatorId: employee.creatorId,
                companyId: employee.companyId,
              ),
            ),
            _buildDrawerItem(
              context: context,
              title: 'Financial Reports',
              destination: ListFinancialManagement(
                creatorId: employee.creatorId,
                companyId: employee.companyId,
              ),
            ),
            // Add more list tiles for other accountant-specific options
          ],
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the Accountant Dashboard!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Here you can manage financial reports, view profiles, and more.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(
      {required BuildContext context,
      required String title,
      required Widget destination}) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
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
}
