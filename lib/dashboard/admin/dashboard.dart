import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:r_and_e_monitor/dashboard/admin/add_member.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/logout_dialog.dart';
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
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_overdue_reminder.dart';

import '../calendar/calendar_converter_screen.dart';

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
        creatorId: AuthService.firebase().currentUser!.id,
      );
      final rents = await rentsStream.first;

      final hasOverdue = rents.any((rent) {
        if (rent.endContract == 'Contract_Ended') {
          return false;
        }
        final dueDate = DateTime.parse(rent.dueDate);
        return DateTime.now().isAfter(dueDate) ||
            DateTime.now().difference(dueDate).inDays >= -5;
      });

      if (mounted) {
        setState(() {
          _hasOverdueRents = hasOverdue;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasOverdueRents = false;
        });
      }
    }
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
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios,
              color: Colors.white, size: 18),
          onTap: onTap,
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          hoverColor: Colors.blueGrey.withValues(alpha: 0.1),
          splashColor: Colors.blueGrey.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          PopupMenuButton<MenuAction>(
            iconSize: 35,
            iconColor: Colors.white,
            color: Colors.white.withValues(alpha: 0.8),
            onSelected: (MenuAction action) async {
              if (action == MenuAction.signOut) {
                bool logoutConfirmed = await showLogOutDialog(context);
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
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
                  color: Colors.black.withValues(alpha: 0.5),
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
              _buildDrawerTile(
                icon: Icons.calendar_today,
                title: 'Calendar Converter',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalendarConverterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.1),
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
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to the Admin Dashboard!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Today is ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            _buildDashboardButton(
                              context: context,
                              icon: Icons.list_alt,
                              label: 'Go to Rent List',
                              color: Colors.blueAccent,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RentList()),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDashboardButton(
                              context: context,
                              icon: Icons.account_balance_wallet,
                              label: 'Financial Management',
                              color: Colors.teal,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FinancialManagementListView()),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_hasOverdueRents)
                              _buildDashboardButton(
                                context: context,
                                icon: Icons.warning_amber_rounded,
                                label: 'Rent Overdue Reminder',
                                color: Colors.red,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RentOverdueReminder()),
                                ),
                              ),
                            const SizedBox(height: 16),
                            _buildDashboardButton(
                              context: context,
                              icon: Icons.calendar_today,
                              label: 'Ethiopian Calendar Converter',
                              color: Colors.purple,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CalendarConverterScreen()),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
    );
  }
}
