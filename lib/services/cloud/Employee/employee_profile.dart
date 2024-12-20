import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:r_and_e_monitor/services/cloud/Employee/create_or_update_employee.dart';
import '../cloud_data_models.dart';

class EmployeeProfile extends StatelessWidget {
  final CloudEmployee employee;

  const EmployeeProfile({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${employee.name} Profile'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  children: [
                    // Enhanced Circle Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        employee.name[0],
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Role
                    Text(
                      employee.role,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Divider(color: Colors.grey.shade400),

                    // Profile Info Cards
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'Email',
                      content: employee.email,
                      onTap: () => _sendEmail(employee.email),
                    ),
                    _buildInfoCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      content: employee.phoneNumber,
                      onTap: () => _makePhoneCall(employee.phoneNumber),
                    ),
                    _buildInfoCard(
                      icon: Icons.attach_money,
                      title: 'Salary',
                      content: _extractSalary(employee.contractInfo),
                    ),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Date Started',
                      content: _extractContractDate(employee.contractInfo),
                    ),
                    const SizedBox(height: 20),

                    // Edit Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateOrUpdateEmployee(employee: employee),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build individual info cards with icons
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Function()? onTap,
  }) {
    return Card(
      color: Colors.black.withValues(alpha: 0.3),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(
          content,
          style: TextStyle(color: Colors.white),
        ),
        onTap: onTap,
      ),
    );
  }

  String _extractSalary(String contractInfo) {
    return contractInfo.split(';')[0].split(':')[1].trim();
  }

  String _extractContractDate(String contractInfo) {
    return contractInfo.split(';')[1].split(':')[1].trim();
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Handle the case where the phone call could not be made
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Hello!'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Handle the case where the email could not be sent
    }
  }
}
