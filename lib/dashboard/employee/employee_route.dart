// employee_route.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';

class EmployeeRoute extends StatelessWidget {
  const EmployeeRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CloudEmployee?>(
      future: _getLoggedInEmployee(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          // If employee not found, navigate to admin dashboard
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, adminDashboardRoute);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          final employee = snapshot.data!;
          return _navigateToDashboard(context, employee);
        }
      },
    );
  }

  Future<CloudEmployee?> _getLoggedInEmployee() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final email = user.email;
    if (email == null) return null;

    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('employees')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return CloudEmployee.fromFirestore(doc);
    } else {
      return null;
    }
  }

  Widget _navigateToDashboard(BuildContext context, CloudEmployee employee) {
    final routeName = '${employee.role}DashboardRoute';
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, routeName, arguments: employee);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
