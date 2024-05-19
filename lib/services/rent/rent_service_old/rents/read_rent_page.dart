// read_rent_page.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/prolong_rent.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/read_property_page.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_penality.dart/rent_penality.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_profile_page.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_service.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/update_rent_form.dart';

import '../../../property_mangement/new/property_service.dart';

class ReadRentPage extends StatelessWidget {
  final int rentId;
  final RentService _rentService = RentService();
  //final RentService _profileService = RentService();
  final PropertyService _propertyService = PropertyService();

  ReadRentPage({Key? key, required this.rentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Rent')),
      body: FutureBuilder<DatabaseRent>(
        future: _rentService.getRent(rentId: rentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          } else {
            final rent = snapshot.data!;
            return FutureBuilder<DatabaseProfile>(
              future: _rentService.getProfile(profileId: rent.profileId),
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
                    future: _propertyService.getProperty(id: rent.id),
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
                                  'Profile: ${profile.companyName ?? profile.firstName}',
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
                                      builder: (context) =>
                                          ReadPropertyPage(propertyId: rent.id),
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
                              Text('Payment Status: ${rent.paymentStatus}'),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateRentPage(
                                        rent: rent,
                                        profiles: [
                                          profile
                                        ], // Pass the actual profiles list
                                        properties: [
                                          property
                                        ], // Pass the actual properties list
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
                                          RentPenaltyPage(rentId: rentId),
                                    ),
                                  );
                                },
                                child: const Text('View Penalties'),
                              ),
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

  void _loadUpdatedRent(BuildContext context, int rentId) {
    _rentService.getRent(rentId: rentId).then((rent) {
      if (rent != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReadRentPage(rentId: rentId),
          ),
        );
      }
    });
  }
}
