//company_detail.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

class CompanyDetailPage extends StatelessWidget {
  final CloudCompany company;

  const CompanyDetailPage({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'companyName-${company.id}',
          child: Text(company.companyName),
        ),
        backgroundColor: const Color.fromARGB(255, 75, 153, 255),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyHeader(),
            const SizedBox(height: 20),
            _buildCompanyDetailCard(
                Icons.person, 'Owner', company.companyOwner),
            _buildCompanyDetailCard(
                Icons.work, 'companyName', company.companyName),
            _buildCompanyDetailCard(
                Icons.location_on, 'Address', company.address),
            _buildCompanyDetailCard(Icons.phone, 'Phone Number', company.phone),
            _buildCompanyDetailCard(Icons.email, 'Email', company.emailAddress),
            //_buildCompanyDetailCard(Icons.web, 'Website', company.website),
            const SizedBox(height: 20),
            _buildContactButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Center(
      child: Column(
        children: [
          // Placeholder for the company logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const Icon(
              Icons.business,
              size: 50,
              color: Color.fromARGB(255, 75, 153, 255),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            company.companyName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 75, 153, 255),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailCard(IconData icon, String label, String value) {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey[400],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 75, 153, 255)),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Handle contact action (e.g., open email client, make a call, etc.)
        },
        icon: const Icon(Icons.email),
        label: const Text('Contact Company'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 75, 153, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        ),
      ),
    );
  }
}
