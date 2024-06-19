import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';
import 'create_or_update_financial_management.dart';

class FinancialManagementListView extends StatelessWidget {
  final RentService _rentService = RentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Management'),
      ),
      body: StreamBuilder<Iterable<CloudFinancialManagement>>(
        stream: _rentService.allFinancialReports(
          creatorId: AuthService.firebase().currentUser!.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final financialReport = data.elementAt(index);

              return ListTile(
                title: Text(financialReport.discription),
                subtitle: Text('Amount: ${financialReport.totalAmount}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateOrUpdateFinancialManagement(
                        financialReport: financialReport,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOrUpdateFinancialManagement(),
            ),
          );
        },
      ),
    );
  }
}
