//read_rent_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/delete_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/profiles/read_profile.dart';
import 'package:r_and_e_monitor/services/cloud/rents/additional_costs.dart';
import 'package:r_and_e_monitor/services/cloud/rents/company_detail.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_property_page.dart';
import '../employee_services/cloud_property_service.dart';
import '../employee_services/cloud_rent_service.dart';

class ReadRentPage extends StatelessWidget {
  final String rentId;
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();

  ReadRentPage({super.key, required this.rentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Rent'),
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
                    alpha: 0.4), // Optional tint for better contrast
              ),
            ),
          ),

          // Main content
          FutureBuilder<CloudRent>(
            future: _rentService.getRent(id: rentId),
            builder: (context, rentSnapshot) {
              if (rentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (rentSnapshot.hasError) {
                return Center(child: Text('Error: ${rentSnapshot.error}'));
              } else if (!rentSnapshot.hasData) {
                return const Center(child: Text('No data found'));
              } else {
                final rent = rentSnapshot.data!;
                return FutureBuilder<CloudProfile>(
                  future: _rentService.getProfile(id: rent.profileId),
                  builder: (context, profileSnapshot) {
                    if (profileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (profileSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${profileSnapshot.error}'));
                    } else if (!profileSnapshot.hasData) {
                      return const Center(child: Text('No profile data found'));
                    } else {
                      final profile = profileSnapshot.data!;
                      return FutureBuilder<CloudProperty>(
                        future:
                            _propertyService.getProperty(id: rent.propertyId),
                        builder: (context, propertySnapshot) {
                          if (propertySnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (propertySnapshot.hasError) {
                            return Center(
                                child:
                                    Text('Error: ${propertySnapshot.error}'));
                          } else if (!propertySnapshot.hasData) {
                            return const Center(
                                child: Text('No property data found'));
                          } else {
                            final property = propertySnapshot.data!;
                            return FutureBuilder<CloudCompany>(
                              future: _rentService.getCompany(
                                  id: profile.companyId),
                              builder: (context, companySnapshot) {
                                if (companySnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (companySnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${companySnapshot.error}'));
                                } else if (!companySnapshot.hasData) {
                                  return const Center(
                                      child: Text('No company data found'));
                                } else {
                                  final company = companySnapshot.data!;
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        _buildProfileCard(context, profile),
                                        const SizedBox(height: 10),
                                        _buildPropertyCard(context, property),
                                        const SizedBox(height: 10),
                                        _buildCompanyCard(context, company),
                                        const SizedBox(height: 20),
                                        _buildRentDetailsCard(context, rent),
                                        const SizedBox(height: 20),
                                        _buildDropdownMenu(
                                            context, rent, profile),
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, CloudProfile profile) {
    return Card(
      color: Colors.transparent,
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.account_circle, color: Colors.lightBlue),
        title: Text(
          '${profile.firstName} ${profile.lastName}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'Company: ${profile.companyName}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.lightBlue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadProfile(profile: profile),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, CloudProperty property) {
    return Card(
      color: Colors.transparent,
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.home, color: Colors.lightBlue),
        title: Text(
          'Property: ${property.propertyType}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'Floor: ${property.floorNumber}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.lightBlue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadPropertyPage(propertyId: property.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, CloudCompany company) {
    return Card(
      color: Colors.transparent,
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.business, color: Colors.lightBlue),
        title: Text(
          company.companyName,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'Owner: ${company.companyOwner}',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.lightBlue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailPage(company: company),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRentDetailsCard(BuildContext context, CloudRent rent) {
    return Card(
      elevation: 4,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rent Details',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
            const Divider(),
            _buildDetailRow('Contract', rent.contract),
            _buildDetailRow('Rent Amount', '\$${rent.rentAmount}'),
            _buildDetailRow('Due Date', rent.dueDate),
            _buildDetailRow('Rent Status', rent.endContract),
            GestureDetector(
              onTap: () =>
                  _showPaymentStatusDialog(context, rent.paymentStatus),
              child: _buildDetailRow('Payment Status', rent.paymentStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.normal, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showPaymentStatusDialog(BuildContext context, String paymentStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close the dialog when tapped outside
          },
          child: Dialog(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: GestureDetector(
              onTap: () {}, // Prevent dialog from closing when tapped inside
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(),
                      _buildPaymentStatusTable(paymentStatus),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentStatusTable(String paymentStatus) {
    final rows = paymentStatus.split('; ');
    final headers = [
      'Payment Count',
      'Advance Payment',
      'Payment Type',
      'Payment Date',
      'Next Payment',
      'Payment Amount',
    ];

    return DataTable(
      border: TableBorder.all(color: Colors.black),
      columns: headers
          .map(
            (header) => DataColumn(
              label: Text(
                header,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
      rows: rows.map((row) {
        // Split the row into individual cells
        final cells = row.split(', ');

        // Ensure each row has exactly 6 cells, fill missing ones if needed
        final paddedCells = List<String>.from(cells);
        while (paddedCells.length < headers.length) {
          paddedCells.add(''); // Add empty string for missing cells
        }

        return DataRow(
          cells: paddedCells
              .map((cell) => DataCell(Text(
                    cell,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )))
              .toList(),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownMenu(
      BuildContext context, CloudRent rent, CloudProfile profile) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
        filled: true,
        fillColor: Colors.lightBlue,
      ),
      isExpanded: true,
      hint: const Text(
        "Options",
        style: TextStyle(color: Colors.white),
      ),
      items: const [
        DropdownMenuItem(value: 'Delete', child: Text('Delete Rent')),
        DropdownMenuItem(
            value: 'AdditionalCosts', child: Text('Penality & Expenses')),
      ],
      onChanged: (String? value) async {
        if (!context.mounted) return; // Check if the widget is still mounted

        switch (value) {
          case 'Delete':
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              await _rentService.deleteRent(id: rent.id);
            }
            break;

          case 'AdditionalCosts':
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdditionalCostsPage(rentId: rent.id),
                ),
              );
            }
            break;

          default:
            break;
        }
      },
    );
  }
}
