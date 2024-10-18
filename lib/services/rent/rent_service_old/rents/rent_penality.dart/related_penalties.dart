//related_penalties.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart'; // Import the property service

class RelatedPenaltiesPage extends StatelessWidget {
  final String profileId;

  const RelatedPenaltiesPage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    final RentService rentService = RentService();
    final PropertyService propertyService =
        PropertyService(); // Initialize the property service

    return Scaffold(
      appBar: AppBar(
        title: const Text('Related Penalties'),
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<List<CloudRent>>(
            future: rentService.getRentsByProfileId(profileId: profileId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No penalties found.'));
              } else {
                // Filter out rents with ended contracts
                final rents = snapshot.data!
                    .where((rent) => rent.endContract != 'Contract_Ended')
                    .toList();

                if (rents.isEmpty) {
                  return const Center(child: Text('No penalties found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(
                      16.0), // Add padding for better spacing
                  itemCount: rents.length,
                  itemBuilder: (context, index) {
                    final rent = rents[index];
                    final dueDate = DateTime.parse(rent.dueDate);
                    final penalty = calculatePenalty(dueDate, rent.rentAmount);
                    final daysPassedOrRemaining =
                        getDaysPassedOrRemaining(dueDate);

                    return FutureBuilder<CloudProperty>(
                      future: propertyService.getProperty(
                          id: rent.propertyId), // Fetch property details
                      builder: (context, propertySnapshot) {
                        if (propertySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (propertySnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${propertySnapshot.error}'));
                        } else if (!propertySnapshot.hasData) {
                          return const Center(
                              child: Text('Property not found.'));
                        } else {
                          final property = propertySnapshot.data!;
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            elevation: 4.0,
                            color: Colors.black.withOpacity(0.1),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                'Contract: ${rent.contract}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                              subtitle: Text(
                                'Property: ${property.propertyNumber}\n'
                                'Due Date: ${rent.dueDate}\n'
                                'Days: $daysPassedOrRemaining\n'
                                'Penalty: \$${penalty.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }

  // Calculate days passed or remaining
  String getDaysPassedOrRemaining(DateTime dueDate) {
    final today = DateTime.now();
    final difference = today.difference(dueDate).inDays;

    if (difference < 0) {
      return '${-difference} days remaining';
    } else if (difference == 0) {
      return 'Rent is due today';
    } else {
      return '$difference days overdue';
    }
  }

  // Calculate the penalty based on days overdue
  double calculatePenalty(DateTime dueDate, double rentAmount) {
    final today = DateTime.now();
    if (today.isAfter(dueDate)) {
      final daysOverdue = today.difference(dueDate).inDays;
      return daysOverdue * (rentAmount * 0.10); // 10% per day overdue
    }
    return 0.0; // No penalty if not overdue
  }
}
