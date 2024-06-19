import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

import '../employee_services/cloud_rent_service.dart';

class ReadCompanyPage extends StatelessWidget {
  final String companyId;
  final RentService _rentService = RentService();

  ReadCompanyPage({Key? key, required this.companyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Company Details')),
      body: FutureBuilder<CloudCompany>(
        future: _rentService.getCompany(id: companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No company data found'));
          } else {
            final company = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Name: ${company.companyName}'),
                  Text('Address: ${company.address}'),
                  Text('Company Owner: ${company.companyOwner}'),
                  Text('Email: ${company.emailAddress}'),
                  Text('Company Name: ${company.phone}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
