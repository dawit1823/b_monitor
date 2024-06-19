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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(),
        child: Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileDetail('Company Name', profile.companyName),
                _buildProfileDetail('First Name', profile.firstName),
                _buildProfileDetail('Last Name', profile.lastName),
                _buildProfileDetail('TIN', profile.tin),
                _buildProfileDetail('Email', profile.email),
                _buildProfileDetail('Phone Number', profile.phoneNumber),
                _buildProfileDetail('Address', profile.address),
                _buildProfileDetail('Contract Info', profile.contractInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0, width: double.infinity),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
