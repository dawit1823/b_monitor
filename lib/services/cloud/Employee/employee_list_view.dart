import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';
import 'create_or_update_employee.dart';

class EmployeeListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RentService _rentService = RentService();
    final creatorId = AuthService.firebase().currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: StreamBuilder<Iterable<CloudEmployee>>(
        stream: _rentService.allEmployees(creatorId: creatorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading employees'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No employees found'));
          }
          final employees = snapshot.data!;
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees.elementAt(index);
              return ListTile(
                title: Text(employee.name),
                subtitle: Text(employee.role),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateOrUpdateEmployee(),
            ),
          );
        },
      ),
    );
  }
}
