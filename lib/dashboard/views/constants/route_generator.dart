// route_generator.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/employee/accountant_dashboard.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  if (settings.name?.endsWith('DashboardRoute') ?? false) {
    final employee = settings.arguments as CloudEmployee;
    switch (employee.role) {
      case 'accountant':
        return MaterialPageRoute(
          builder: (context) => AccountantDashboard(employee: employee),
        );
      // Add other roles here as needed
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Unknown role: ${employee.role}'),
            ),
          ),
        );
    }
  }
  return null;
}
