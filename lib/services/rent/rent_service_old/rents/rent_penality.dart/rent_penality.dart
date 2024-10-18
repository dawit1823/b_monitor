import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'related_penalties.dart';

class RentPenaltyPage extends StatefulWidget {
  final String rentId;
  const RentPenaltyPage({super.key, required this.rentId});

  @override
  State<RentPenaltyPage> createState() => _RentPenaltyPageState();
}

class _RentPenaltyPageState extends State<RentPenaltyPage> {
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  late Future<CloudRent> _rent;

  @override
  void initState() {
    super.initState();
    _rent = _rentService.getRent(id: widget.rentId);
  }

  double calculatePenalty(DateTime dueDate, double rentAmount) {
    final today = DateTime.now();
    if (today.isAfter(dueDate)) {
      final daysOverdue = today.difference(dueDate).inDays;
      return daysOverdue * (rentAmount * 0.10); // 10% per day overdue
    }
    return 0.0;
  }

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CloudRent>(
      future: _rent,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Rent not found.'));
        } else {
          final rent = snapshot.data!;
          final dueDate = DateTime.parse(rent.dueDate);
          final daysPassedOrRemaining = getDaysPassedOrRemaining(dueDate);
          final penalty = calculatePenalty(dueDate, rent.rentAmount);

          return FutureBuilder<CloudProfile>(
            future: _rentService.getProfile(id: rent.profileId),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (profileSnapshot.hasError) {
                return Center(child: Text('Error: ${profileSnapshot.error}'));
              } else if (!profileSnapshot.hasData) {
                return const Center(child: Text('Profile not found.'));
              } else {
                final profile = profileSnapshot.data!;
                return FutureBuilder<CloudProperty>(
                  future: _propertyService.getProperty(id: rent.propertyId),
                  builder: (context, propertySnapshot) {
                    if (propertySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (propertySnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${propertySnapshot.error}'));
                    } else if (!propertySnapshot.hasData) {
                      return const Center(child: Text('Property not found.'));
                    } else {
                      final property = propertySnapshot.data!;
                      return Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/bg/background_dashboard.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 4.0,
                                color: Colors.white.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Profile: ${profile.companyName.isNotEmpty ? profile.companyName : profile.firstName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Property: ${property.propertyNumber}\nContract: ${rent.contract}\nDue Date: ${rent.dueDate}\nDays: $daysPassedOrRemaining\nPenalty: \$${penalty.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: daysPassedOrRemaining
                                                  .contains('overdue')
                                              ? Colors.redAccent
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RelatedPenaltiesPage(
                                                profileId: rent.profileId),
                                      ),
                                    );
                                  },
                                  child: const Text('View Related Penalties'),
                                ),
                              ),
                            ],
                          ),
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
}
