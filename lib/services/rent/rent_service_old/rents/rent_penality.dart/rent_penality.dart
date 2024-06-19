import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'related_penalties.dart'; // Import the related penalties page

class RentPenaltyPage extends StatefulWidget {
  final String rentId;
  const RentPenaltyPage({Key? key, required this.rentId}) : super(key: key);

  @override
  State<RentPenaltyPage> createState() => _RentPenaltyPageState();
}

class _RentPenaltyPageState extends State<RentPenaltyPage> {
  final RentService _rentService = RentService();
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
    return 0.0; // No penalty if not overdue
  }

  String getDaysPassed(DateTime dueDate) {
    final today = DateTime.now();
    final daysPassed = today.difference(dueDate).inDays;

    if (daysPassed < 0 && daysPassed >= -5) {
      return 'You have ${-daysPassed} days left';
    } else if (daysPassed >= 0) {
      return 'You have $daysPassed days overdue';
    } else {
      return '${-daysPassed} days left';
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
          final daysPassed = getDaysPassed(dueDate);
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
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                          'Profile: ${profile.companyName.isNotEmpty ? profile.companyName : profile.firstName}'),
                      subtitle: Text(
                        'Due Date: ${rent.dueDate}\nDays Passed: $daysPassed\nPenalty: \$${penalty.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: daysPassed.contains('overdue')
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RelatedPenaltiesPage(profileId: rent.profileId),
                        ));
                      },
                      child: const Text('View Related Penalties'),
                    ),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }
}
