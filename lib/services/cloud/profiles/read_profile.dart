// read_profile.dart
import 'package:flutter/material.dart';

import '../cloud_data_models.dart';

class ReadProfile extends StatelessWidget {
  final CloudProfile profile;

  const ReadProfile({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company Name: ${profile.companyName}',
                style: TextStyle(fontSize: 18)),
            Text('First Name: ${profile.firstName}',
                style: TextStyle(fontSize: 18)),
            Text('Last Name: ${profile.lastName}',
                style: TextStyle(fontSize: 18)),
            Text('TIN: ${profile.tin}', style: TextStyle(fontSize: 18)),
            Text('Email: ${profile.email}', style: TextStyle(fontSize: 18)),
            Text('Phone Number: ${profile.phoneNumber}',
                style: TextStyle(fontSize: 18)),
            Text('Address: ${profile.address}', style: TextStyle(fontSize: 18)),
            Text('Contract Info: ${profile.contractInfo}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
