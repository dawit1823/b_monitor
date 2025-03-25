import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:r_and_e_monitor/dashboard/calendar/calendar_converter_screen.dart';
import 'package:r_and_e_monitor/dashboard/employee/service/financial_management/financial_report_employee.dart';
import 'package:r_and_e_monitor/dashboard/employee/service/financial_management/list_financial_management.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/logout_dialog.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/profile/list_profile_employee.dart';
import '../../services/cloud/employee_services/property/list_property.dart';
import '../../services/cloud/employee_services/rents/list_rent_employee.dart';

class AccountantDashboard extends StatelessWidget {
  final CloudEmployee employee;

  const AccountantDashboard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${employee.name} - Accountant Dashboard',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () async {
              bool logoutConfirmed = await showLogOutDialog(context);
              if (logoutConfirmed) {
                await AuthService.firebase().signOut();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, landingPageRoute);
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              // Background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg/accountant_dashboard.jpg'),
                    fit: BoxFit.cover,
                    opacity: 0.8,
                  ),
                ),
              ),
              // Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    color: Colors.black.withValues(alpha: 0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome to Your Dashboard!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Display the current date and time
                          Text(
                            'Today is ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Current time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Responsive button layout
                          orientation == Orientation.portrait
                              ? _buildButton(context)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildButton(context),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Create a method to build a button to keep code DRY
  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinancialManagementReportEmployee(
              companyId: employee.companyId,
              creatorId: employee.creatorId,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text(
        'Financial managment',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // Background image for the Drawer menu
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/accountant_dashboard.jpg'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
          ),
          // Drawer content
          ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(employee.name),
                accountEmail: Text(employee.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    employee.name[0],
                    style: const TextStyle(fontSize: 40.0),
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 66, 143, 107),
                ),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Profile List',
                icon: Icons.person,
                destination: ListProfileEmployee(
                  creatorId: employee.creatorId,
                  companyId: employee.companyId,
                ),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Property List',
                icon: Icons.home,
                destination: ListProperty(
                  creatorId: employee.creatorId,
                  companyId: employee.companyId,
                ),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Rent List',
                icon: Icons.receipt,
                destination: ListRentEmployee(
                  creatorId: employee.creatorId,
                  companyId: employee.companyId,
                ),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Financial Reports',
                icon: Icons.assessment,
                destination: ListFinancialManagement(
                  creatorId: employee.creatorId,
                  companyId: employee.companyId,
                ),
              ),
              _buildDrawerItem(
                context: context,
                title: 'Date Converter',
                icon: Icons.calendar_today,
                destination: CalendarConverterScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style:
            const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
