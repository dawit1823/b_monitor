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
        backgroundColor: const Color.fromARGB(255, 75, 153, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                employee.name[0],
                style: const TextStyle(
                    fontSize: 40, color: Color.fromARGB(255, 75, 153, 255)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              employee.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 75, 153, 255),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              employee.role,
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade400),
            ListTile(
              leading: const Icon(Icons.email,
                  color: Color.fromARGB(255, 75, 153, 255)),
              title: const Text('Email'),
              subtitle: Text(employee.email),
              onTap: () => _sendEmail(employee.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone,
                  color: Color.fromARGB(255, 75, 153, 255)),
              title: const Text('Phone Number'),
              subtitle: Text(employee.phoneNumber),
              onTap: () => _makePhoneCall(employee.phoneNumber),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money,
                  color: Color.fromARGB(255, 75, 153, 255)),
              title: const Text('Salary'),
              subtitle: Text(_extractSalary(employee.contractInfo)),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today,
                  color: Color.fromARGB(255, 75, 153, 255)),
              title: const Text('Date Started'),
              subtitle: Text(_extractContractDate(employee.contractInfo)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateOrUpdateEmployee(employee: employee),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 75, 153, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
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
