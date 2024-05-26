import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

import '../../../cloud/services/cloud_rent_service.dart';

class ReadProfilePage extends StatelessWidget {
  final String profileId;
  final RentService _profileService = RentService();

  ReadProfilePage({Key? key, required this.profileId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Profile')),
      body: FutureBuilder<CloudProfile>(
        future: _profileService.getProfile(id: profileId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final profile = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Name: ${profile.companyName ?? "N/A"}'),
                  Text('First Name: ${profile.firstName ?? "N/A"}'),
                  Text('First Name: ${profile.lastName ?? "N/A"}'),
                  Text('TIN: ${profile.tin ?? "N/A"}'),
                  Text('Email: ${profile.email}'),
                  Text('Phone: ${profile.phoneNumber}'),
                  Text('Contract Info: ${profile.contractInfo}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
