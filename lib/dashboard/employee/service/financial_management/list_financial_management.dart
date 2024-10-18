//list_financial_management.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/employee/service/financial_management/financial_report_employee.dart';
import 'package:r_and_e_monitor/dashboard/employee/service/financial_management/read_financial_management_employee.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'create_or_update_financial_management.dart';

class ListFinancialManagement extends StatelessWidget {
  final RentService _rentService = RentService();
  final String creatorId;
  final String companyId;

  ListFinancialManagement({
    super.key,
    required this.creatorId,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management'),
        backgroundColor:
            Color.fromARGB(255, 66, 143, 107), // Customize AppBar color
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg/accountant_dashboard.jpg'), // Add your background image
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<Iterable<CloudFinancialManagement>>(
          stream: _rentService.getFinancialReportsByCreatorAndCompany(
            creatorId: creatorId,
            companyId: companyId,
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

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.transparent,
                        elevation: 5,
                        child: ExpansionTile(
                          leading: const Icon(Icons.business,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          title: Text(
                            'Company: $companyName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          children: [
                            ListTile(
                              title: const Text(
                                'View Financial Report',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              trailing: const Icon(Icons.insert_chart_outlined),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FinancialManagementReportEmployee(
                                      companyId: companyId,
                                      creatorId: creatorId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ...reports.map((report) {
                              return ListTile(
                                title: Text(
                                  report.discription,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Amount: ${report.totalAmount}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReadFinancialManagementEmployee(
                                        report: report,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreateOrUpdateFinancialManagement(
                                        report: report,
                                        creatorId: creatorId,
                                        companyId: companyId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        child: const Icon(Icons.add),
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
