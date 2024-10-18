import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/dashboard/admin/add_member.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/enums/menu_action.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';
import 'package:r_and_e_monitor/services/cloud/Employee/employee_list_view.dart';
import 'package:r_and_e_monitor/services/cloud/company/list_company.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/financial_management/financial_management_list_view.dart';
import 'package:r_and_e_monitor/services/cloud/property/property_view.dart';
import 'package:r_and_e_monitor/services/cloud/rents/rent_list.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/profile_view.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_overdue_reminder.dart'; // Import the RentOverdueReminder class

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final RentService _rentService;
  bool _hasOverdueRents = false;

  @override
  void initState() {
    super.initState();
    _rentService = RentService();
    _checkOverdueRents();
  }

  Future<void> _checkOverdueRents() async {
    try {
      final rentsStream = _rentService.allRents(
          creatorId: AuthService.firebase().currentUser!.id);
      final rents = await rentsStream.first;

      setState(() {
        _hasOverdueRents = rents.any((rent) {
          final dueDate = DateTime.parse(rent.dueDate);
          return DateTime.now().isAfter(dueDate);
        });
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<bool> showLogoutDialog(BuildContext context) async {
    if (!context.mounted) return false;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: Colors.deepPurple, size: 18),
          onTap: onTap,
          tileColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          hoverColor: Colors.deepPurple.withOpacity(0.1),
          splashColor: Colors.deepPurple.withOpacity(0.2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (MenuAction action) async {
              if (action == MenuAction.signOut) {
                bool logoutConfirmed = await showLogoutDialog(context);
                if (logoutConfirmed && context.mounted) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
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
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            image: DecorationImage(
              image: AssetImage('assets/bg/background_dashboard.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.5), // Semi-transparent overlay
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    'Main Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildDrawerTile(
                icon: Icons.business,
                title: 'Companies / ድርጅቶች',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListCompany()),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.person,
                title: 'Tenant / ተከራይ',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileView()),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.home,
                title: 'Property / የሚከራይ ንብረት',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PropertyView()),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.attach_money,
                title: 'Rent / ኪራይ',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RentList()),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.people,
                title: 'Employee / ሰራተኛ',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmployeeListView()),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.account_balance_wallet,
                title: 'Financial Management / ፋይናንስ',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FinancialManagementListView()),
                  );
                },
              ),
              _buildDrawerTile(
                icon: Icons.person_add,
                title: 'Add Member',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMemberPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/bg/background_dashboard.jpg', // Ensure the image is added in assets and pubspec.yaml
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthStateLoggedOut && context.mounted) {
                  Navigator.pushReplacementNamed(context, landingPageRoute);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8.0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to the Admin Dashboard!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a tool from the menu to manage the system.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // const SizedBox(height: 20),
              ),
            ),
          ),

          if (_hasOverdueRents)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Alerting color
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RentOverdueReminder()),
                );
              },
              child: const Text(
                'Rent Overdue Reminder',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
