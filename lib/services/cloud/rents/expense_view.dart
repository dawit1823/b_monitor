import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/rents/create_or_update_expense.dart';
import '../employee_services/cloud_rent_service.dart';

class ExpenseView extends StatelessWidget {
  final String rentId;
  final RentService _rentService = RentService();

  ExpenseView({super.key, required this.rentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Iterable<CloudExpenses>>(
        stream: _rentService.getExpensesByRentIdStream(rentId: rentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses found'));
          } else {
            final expenses = snapshot.data!;
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses.elementAt(index);
                return ListTile(
                  title: Text(expense.expenceType),
                  subtitle: Text(expense.discription),
                  trailing: Text('\$${expense.amount}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrUpdateExpense(
                          expense: expense,
                          rentId: rentId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOrUpdateExpense(
                rentId: rentId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
