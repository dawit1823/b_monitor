import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_service.dart'; // Adjust the import according to your project structure

class ProfileReadPage extends StatelessWidget {
  final DatabaseProfile profile;

  const ProfileReadPage({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company Name: ${profile.companyName ?? "N/A"}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('First Name: ${profile.firstName ?? "N/A"}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Last Name: ${profile.lastName ?? "N/A"}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('TIN: ${profile.tin ?? "N/A"}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Phone Number: ${profile.phoneNumber}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Email: ${profile.email}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Contract Info: ${profile.contractInfo}',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
