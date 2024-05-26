import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/additional_costs.dart';
import 'package:r_and_e_monitor/services/cloud/rents/create_or_update_rents.dart';
import 'package:r_and_e_monitor/services/cloud/rents/prolong_rent.dart';
import 'package:r_and_e_monitor/services/cloud/rents/read_property_page.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_profile_page.dart';
import '../services/cloud_property_service.dart';
import '../services/cloud_rent_service.dart';

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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final rent = snapshot.data!;
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
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadProfilePage(
                                          profileId: rent.profileId),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Profile: ${profile.companyName != "" ? profile.companyName : profile.firstName}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadPropertyPage(
                                          propertyId: rent.propertyId),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Property: ${property.propertyNumber} (${property.propertyType})',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text('Contract: ${rent.contract}'),
                              Text('Rent Amount: ${rent.rentAmount}'),
                              Text('Due Date: ${rent.dueDate}'),
                              Text('Rent Status: ${rent.endContract}'),
                              Text('Payment Status: ${rent.paymentStatus}'),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  final profiles = await _rentService
                                      .allProfiles(creatorId: rent.creatorId)
                                      .first;
                                  final properties = await _propertyService
                                      .allProperties(creatorId: rent.creatorId)
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
                                      // Reload data if the rent was updated
                                      _loadUpdatedRent(context, rentId);
                                    }
                                  });
                                },
                                child: const Text('Edit Rent'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AdditionalCostsPage(rentId: rentId),
                                    ),
                                  );
                                },
                                child: const Text('Additional Costs'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProlongRentFormWidget(rentId: rentId),
                                    ),
                                  );
                                },
                                child: const Text('Prolong Rent'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _endContract(context, rent),
                                child: const Text('End Contract'),
                              ),
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
      ),
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
