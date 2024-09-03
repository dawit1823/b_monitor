import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/dashboard/admin/add_member.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/enums/menu_action.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';
import 'package:r_and_e_monitor/services/cloud/employee/employee_list_view.dart';
import 'package:r_and_e_monitor/services/cloud/rents/rent_list.dart';
import 'package:r_and_e_monitor/services/cloud/property/property_view.dart';
import 'package:r_and_e_monitor/services/cloud/company/list_company.dart';
import 'package:r_and_e_monitor/services/cloud/financial_management/financial_management_list_view.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/profile_view.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
              title: const Text('Profile View'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileView()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Property View'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PropertyView()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('List Rent'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RentList()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Employee List'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmployeeListView()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Companies'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListCompany()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Financial Management'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FinancialManagementListView()),
                  );
                }
              },
            ),
            ListTile(
              title: const Text('Add Member'),
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMemberPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthStateLoggedOut && context.mounted) {
            Navigator.pushReplacementNamed(context, landingPageRoute);
          }
        },
        child: Padding(
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
      ),
    );
  }
}
