import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_service.dart';

class RentPenaltyPage extends StatefulWidget {
  final int rentId; // Accept a rentId
  const RentPenaltyPage({Key? key, required this.rentId}) : super(key: key);

  @override
  State<RentPenaltyPage> createState() => _RentPenaltyPageState();
}

class _RentPenaltyPageState extends State<RentPenaltyPage> {
  final RentService _rentService = RentService();
  late Future<DatabaseRent> _rent;

  @override
  void initState() {
    super.initState();
    _rent = _rentService.getRent(rentId: widget.rentId); // Fetch rent by ID
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
    if (daysPassed - 5 <= 0) {
      return 'you have $daysPassed days left'.toString();
    }
    return daysPassed.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent Penalty')),
      body: FutureBuilder<DatabaseRent>(
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
            return ListTile(
              title: Text('Profile ID: ${rent.profileId}'),
              subtitle: Text(
                'Due Date: ${rent.dueDate}\nDays Passed: $daysPassed  \nPenalty: \$${penalty.toStringAsFixed(2)}',
              ),
            );
          }
        },
      ),
    );
  }
}
