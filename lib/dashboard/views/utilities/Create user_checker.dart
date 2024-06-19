// user_checker.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

class UserChecker {
  static Future<void> checkUser(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return; // Handle the case when there is no logged-in user
    }

    final email = user.email;
    if (email == null) {
      return; // Handle the case when email is not available
    }

    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('employees')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final employee = CloudEmployee.fromFirestore(doc);
      final routeName = '${employee.role}DashboardRoute';
      Navigator.pushReplacementNamed(context, routeName, arguments: employee);
    } else {
      Navigator.pushReplacementNamed(context, adminDashboardRoute);
    }
  }
}
