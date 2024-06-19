// related_penalties.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';

class RelatedPenaltiesPage extends StatelessWidget {
  final String profileId;

  const RelatedPenaltiesPage({Key? key, required this.profileId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RentService _rentService = RentService();

    return Scaffold(
      appBar: AppBar(title: const Text('Related Penalties')),
      body: FutureBuilder<List<CloudRent>>(
        future: _rentService.getRentsByProfileId(profileId: profileId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No penalties found.'));
          } else {
            final rents = snapshot.data!;
            return ListView.builder(
              itemCount: rents.length,
              itemBuilder: (context, index) {
                final rent = rents[index];
                final dueDate = DateTime.parse(rent.dueDate);
                final penalty = calculatePenalty(dueDate, rent.rentAmount);
                return ListTile(
                  title: Text('Rent: ${rent.contract}'),
                  subtitle: Text(
                      'Due Date: ${rent.dueDate}\nPenalty: \$${penalty.toStringAsFixed(2)}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  double calculatePenalty(DateTime dueDate, double rentAmount) {
    final today = DateTime.now();
    if (today.isAfter(dueDate)) {
      final daysOverdue = today.difference(dueDate).inDays;
      return daysOverdue * (rentAmount * 0.10); // 10% per day overdue
    }
    return 0.0; // No penalty if not overdue
  }
}
