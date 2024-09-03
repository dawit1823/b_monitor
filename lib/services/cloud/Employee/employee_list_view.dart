//employee_list_view.dart
import 'package:flutter/material.dart';
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
      body: StreamBuilder<Iterable<CloudEmployee>>(
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
              if (companySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (companySnapshot.hasError) {
                return const Center(child: Text('Error loading company names'));
              }
              if (!companySnapshot.hasData || companySnapshot.data!.isEmpty) {
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
                  return ExpansionTile(
                    title: Text(companyName),
                    children: employees.map((employee) {
                      return ListTile(
                        title: Text(employee.name),
                        subtitle: Text(employee.role),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CreateOrUpdateEmployee(
                                  employee: employee,
                                ),
                              ),
                            );
                          },
                        ),
                        // Inside the ExpansionTile's ListTile
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EmployeeProfile(employee: employee),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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
