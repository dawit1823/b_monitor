import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/rents/expense_view.dart';
import '../../rent/rent_service_old/rents/rent_penality.dart/rent_penality.dart'; // Update with correct import

class AdditionalCostsPage extends StatelessWidget {
  final String rentId;

  const AdditionalCostsPage({super.key, required this.rentId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Additional Costs'),
          bottom: const TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Colors.black, // Change tab text color to white
            tabs: [
              Tab(text: 'Penalties'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RentPenaltyPage(rentId: rentId),
            ExpenseView(rentId: rentId),
          ],
        ),
      ),
    );
  }
}
