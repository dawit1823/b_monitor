//company_detail.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/delete_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/company/create_or_update_companies.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';

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
        elevation: 0,
      ),
      body: Stack(
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyHeader(),
                const SizedBox(height: 20),
                _buildCompanyDetailCard(
                    Icons.person, 'Owner', company.companyOwner),
                _buildCompanyDetailCard(
                    Icons.work, 'Company Name', company.companyName),
                _buildCompanyDetailCard(
                    Icons.location_on, 'Address', company.address),
                _buildCompanyDetailCard(
                    Icons.phone, 'Phone Number', company.phone),
                _buildCompanyDetailCard(
                    Icons.email, 'Email', company.emailAddress),
                const SizedBox(height: 20),
                _buildContactButton(context),
                const SizedBox(height: 20),
                _buildDeleteButton(context),
              ],
            ),
          ),
        ],
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
                  spreadRadius: 4,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.business,
              size: 50,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            company.companyName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailCard(IconData icon, String label, String value) {
    return Card(
      elevation: 4,
      color: Colors.transparent.withValues(alpha: 0.1),
      shadowColor: Colors.transparent.withValues(alpha: 0.8),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        tileColor: Colors.black.withValues(alpha: 0.1),
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final shouldDelete = await showDeleteDialog(context);

          if (shouldDelete) {
            if (!context.mounted) {
              return;
            }
            // Call delete functionality here
            await _deleteCompany(context);
          }
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        label: const Text('Delete Company'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Red to signify delete action
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _deleteCompany(BuildContext context) async {
    try {
      final RentService rentService = RentService();
      await rentService.deleteCompany(
          id: company.id); // Delete company using ID
      if (context.mounted) {
        Navigator.pop(context); // Navigate back after deletion
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      // Handle deletion error here, maybe show a snackbar or alert dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the company')),
      );
    }
  }

  Widget _buildContactButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOrUpdateCompany(
                  company: company), // Pass existing company data
            ),
          );
        },
        icon: const Icon(
          Icons.email,
          color: Colors.white,
        ),
        label: const Text('Update Company'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
          elevation: 4,
        ),
      ),
    );
  }
}
