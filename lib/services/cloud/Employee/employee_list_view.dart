import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/delete_dialog.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/Employee/employee_profile.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';
import 'create_or_update_employee.dart';

class EmployeeListView extends StatelessWidget {
  const EmployeeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final RentService rentService = RentService();
    final creatorId = AuthService.firebase().currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
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
                color: Colors.black.withValues(
                    alpha: 0.2), // Optional tint for better contrast
              ),
            ),
          ),
          StreamBuilder<Iterable<CloudEmployee>>(
            stream: rentService.allEmployees(creatorId: creatorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading employees'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No employees found'));
              }
              final employees = snapshot.data!;
              return FutureBuilder<Map<String, String>>(
                future: rentService.getCompanyNames(
                    employees.map((e) => e.companyId).toSet().toList()),
                builder: (context, companySnapshot) {
                  if (companySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (companySnapshot.hasError) {
                    return const Center(
                        child: Text('Error loading company names'));
                  }
                  if (!companySnapshot.hasData ||
                      companySnapshot.data!.isEmpty) {
                    return const Center(child: Text('No companies found'));
                  }
                  final companyNames = companySnapshot.data!;
                  final groupedEmployees =
                      _groupEmployeesByCompany(employees, companyNames);
                  return ListView.builder(
                    itemCount: groupedEmployees.length,
                    itemBuilder: (context, index) {
                      final companyId = groupedEmployees.keys.elementAt(index);
                      final companyName = companyNames[companyId] ?? 'Unknown';
                      final employees = groupedEmployees[companyId]!;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: ExpansionTile(
                          collapsedIconColor: Colors.white,
                          iconColor: Colors.lightBlue,
                          title: Text(
                            companyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          children: employees.map((employee) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 3.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 16.0),
                              child: ListTile(
                                title: Text(
                                  employee.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(employee.role),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.lightBlue,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateOrUpdateEmployee(
                                              employee: employee,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final shouldDelete =
                                            await showDeleteDialog(context);
                                        if (shouldDelete) {
                                          await rentService.deleteEmployee(
                                              id: employee.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EmployeeProfile(employee: employee),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateOrUpdateEmployee(),
            ),
          );
        },
      ),
    );
  }

  Map<String, List<CloudEmployee>> _groupEmployeesByCompany(
      Iterable<CloudEmployee> employees, Map<String, String> companyNames) {
    final Map<String, List<CloudEmployee>> groupedEmployees = {};
    for (var employee in employees) {
      if (!groupedEmployees.containsKey(employee.companyId)) {
        groupedEmployees[employee.companyId] = [];
      }
      groupedEmployees[employee.companyId]!.add(employee);
    }
    return groupedEmployees;
  }
}
