//read_rent_page.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/additional_costs.dart';
import 'package:r_and_e_monitor/services/cloud/rents/create_or_update_rents.dart';
import 'package:r_and_e_monitor/services/cloud/rents/prolong_rent.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_property_page.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_profile_page.dart';
import '../company/read_company.dart';
import '../reports/create_or_update_report_view.dart';
import '../reports/report_view_page.dart';
import '../employee_services/cloud_property_service.dart';
import '../employee_services/cloud_rent_service.dart';

class ReadRentPage extends StatelessWidget {
  final String rentId;
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();

  ReadRentPage({Key? key, required this.rentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Rent')),
      body: FutureBuilder<CloudRent>(
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
                  return Center(child: Text('Error: ${profileSnapshot.error}'));
                } else if (!profileSnapshot.hasData) {
                  return const Center(child: Text('No profile data found'));
                } else {
                  final profile = profileSnapshot.data!;
                  return FutureBuilder<DatabaseProperty>(
                    future: _propertyService.getProperty(id: rent.propertyId),
                    builder: (context, propertySnapshot) {
                      if (propertySnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (propertySnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${propertySnapshot.error}'));
                      } else if (!propertySnapshot.hasData) {
                        return const Center(
                            child: Text('No property data found'));
                      } else {
                        final property = propertySnapshot.data!;
                        return FutureBuilder<CloudCompany>(
                          future:
                              _rentService.getCompany(id: profile.companyId),
                          builder: (context, companySnapshot) {
                            if (companySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (companySnapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Error: ${companySnapshot.error}'));
                            } else if (!companySnapshot.hasData) {
                              return const Center(
                                  child: Text('No company data found'));
                            } else {
                              final company = companySnapshot.data!;
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProfileText(context, profile),
                                    _buildPropertyText(context, property),
                                    _buildCompanyText(context, company),
                                    _buildRentDetails(rent),
                                    const SizedBox(height: 20),
                                    _buildActionButton(context, 'Edit Rent',
                                        () async {
                                      final profiles = await _rentService
                                          .allProfiles(
                                              creatorId: rent.creatorId)
                                          .first;
                                      final properties = await _propertyService
                                          .allProperties(
                                              creatorId: rent.creatorId)
                                          .first;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateOrUpdateRentView(
                                            rent: rent,
                                            profiles: profiles.toList(),
                                            properties: properties.toList(),
                                          ),
                                        ),
                                      ).then((updatedRent) {
                                        if (updatedRent != null) {
                                          _loadUpdatedRent(context, rentId);
                                        }
                                      });
                                    }),
                                    const SizedBox(height: 20),
                                    _buildActionButton(
                                        context, 'Additional Costs', () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AdditionalCostsPage(
                                                  rentId: rentId),
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 20),
                                    _buildActionButton(context, 'Prolong Rent',
                                        () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProlongRentFormWidget(
                                                  rentId: rentId),
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 20),
                                    _buildActionButton(context, 'End Contract',
                                        () => _endContract(context, rent)),
                                    const SizedBox(height: 20),
                                    _buildActionButton(
                                        context, 'Create or Update Report', () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateOrUpdateReportView(
                                            rentId: rentId,
                                            companyId: profile.companyId,
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 20),
                                    _buildActionButton(context, 'View Reports',
                                        () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReportViewPage(rentId: rentId),
                                        ),
                                      );
                                    }),
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
    );
  }

  Widget _buildProfileText(BuildContext context, CloudProfile profile) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadProfilePage(profileId: profile.id),
          ),
        );
      },
      child: Text(
        'Profile: ${profile.companyName} - ${profile.firstName} ${profile.lastName}',
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildPropertyText(BuildContext context, DatabaseProperty property) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadPropertyPage(propertyId: property.id),
          ),
        );
      },
      child: Text(
        'Property: ${property.propertyType}, Floor: ${property.floorNumber}',
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildCompanyText(BuildContext context, CloudCompany company) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadCompanyPage(companyId: company.id),
          ),
        );
      },
      child: Text(
        'Company: ${company.companyName}, Owner: ${company.companyOwner}',
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildRentDetails(CloudRent rent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contract: ${rent.contract}'),
        Text('Rent Amount: ${rent.rentAmount}'),
        Text('Due Date: ${rent.dueDate}'),
        Text('Rent Status: ${rent.endContract}'),
        Text('Payment Status: ${rent.paymentStatus}'),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  void _loadUpdatedRent(BuildContext context, String rentId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReadRentPage(rentId: rentId),
      ),
    );
  }

  Future<void> _endContract(BuildContext context, CloudRent rent) async {
    try {
      await _rentService.updateRent(
        id: rent.id,
        rentAmount: rent.rentAmount,
        contract: rent.contract,
        dueDate: rent.dueDate,
        endContract: 'Contract_Ended',
        paymentStatus: rent.paymentStatus,
      );
      _loadUpdatedRent(context, rent.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end contract: $e')),
      );
    }
  }
}
