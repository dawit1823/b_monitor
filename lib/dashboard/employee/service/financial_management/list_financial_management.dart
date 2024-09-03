// list_financial_management.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'create_or_update_financial_management.dart';

class ListFinancialManagement extends StatelessWidget {
  final String creatorId;
  final String companyId;

  const ListFinancialManagement({
    super.key,
    required this.creatorId,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final RentService rentService = RentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management List'),
      ),
      body: StreamBuilder<Iterable<CloudFinancialManagement>>(
        stream: rentService.allFinancialReports(creatorId: creatorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading financial reports.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No financial reports found.'));
          }

          final reports = snapshot.data!.where((report) =>
              report.companyId == companyId && report.creatorId == creatorId);

          if (reports.isEmpty) {
            return const Center(child: Text('No financial reports found.'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports.elementAt(index);
              return ListTile(
                title: Text(report.discription),
                subtitle: Text('Amount: ${report.totalAmount}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrUpdateFinancialManagement(
                          report: report,
                          creatorId: creatorId,
                          companyId: companyId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOrUpdateFinancialManagement(
                creatorId: creatorId,
                companyId: companyId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
