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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg/background_dashboard.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<Iterable<CloudExpenses>>(
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
                padding: const EdgeInsets.all(16.0),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses.elementAt(index);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        expense.expenceType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Text(expense.discription),
                      trailing: Text(
                        '\$${expense.amount}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        label: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
}
