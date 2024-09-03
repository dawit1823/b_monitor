//financial_management_list_view.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/financial_management/financial_management_report.dart';
import '../../auth/auth_service.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';
import 'create_or_update_financial_management.dart';

class FinancialManagementListView extends StatelessWidget {
  final RentService _rentService = RentService();

  FinancialManagementListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management'),
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
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];

          final groupedData = _groupFinancialReportsByCompany(data);

          return ListView.builder(
            itemCount: groupedData.keys.length,
            itemBuilder: (context, index) {
              final companyId = groupedData.keys.elementAt(index);
              final reports = groupedData[companyId]!;
              return FutureBuilder<CloudCompany>(
                future: _rentService.getCompanyById(companyId: companyId),
                builder: (context, companySnapshot) {
                  if (companySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (companySnapshot.hasError) {
                    return ListTile(
                      title: const Text('Error loading company name'),
                      subtitle: Text(companyId),
                    );
                  }
                  final company = companySnapshot.data;
                  final companyName = company?.companyName ?? 'Unknown';

                  return ExpansionTile(
                    title: Text('Company: $companyName'),
                    children: [
                      ListTile(
                        title: const Text('View Financial Report'),
                        trailing: const Icon(Icons.insert_chart_outlined),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FinancialManagementReport(
                                  companyId: companyId),
                            ),
                          );
                        },
                      ),
                      ...reports.map((report) {
                        return ListTile(
                          title: Text(report.discription),
                          subtitle: Text('Amount: ${report.totalAmount}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateOrUpdateFinancialManagement(
                                  financialReport: report,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOrUpdateFinancialManagement(),
            ),
          );
        },
      ),
    );
  }

  Map<String, List<CloudFinancialManagement>> _groupFinancialReportsByCompany(
      Iterable<CloudFinancialManagement> reports) {
    final Map<String, List<CloudFinancialManagement>> groupedReports = {};
    for (var report in reports) {
      final companyId = report.companyId;
      if (!groupedReports.containsKey(companyId)) {
        groupedReports[companyId] = [];
      }
      groupedReports[companyId]!.add(report);
    }
    return groupedReports;
  }
}
