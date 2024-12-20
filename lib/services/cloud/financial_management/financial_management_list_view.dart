//financial_management_list_view.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/employee/service/financial_management/read_financial_management_employee.dart';
import 'package:r_and_e_monitor/services/cloud/financial_management/financial_management_report.dart';
import '../../../dashboard/views/utilities/dialogs/delete_dialog.dart';
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
        title: const Text(
          'Financial Management',
          style: TextStyle(color: Colors.white), // Ensure text is readable
        ),
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg/accountant_dashboard.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black
                  .withValues(alpha: 0.5), // Semi-transparent overlay
            ),
          ],
        ),
        backgroundColor: Colors.transparent
            .withValues(alpha: 0.8), // Transparent to show the image
        elevation: 0, // Optional: Removes shadow for a cleaner look
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(
                    alpha: 0.2), // Optional tint for better contrast
              ),
            ),
          ),
          StreamBuilder<Iterable<CloudFinancialManagement>>(
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

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.transparent,
                          elevation: 5,
                          child: ExpansionTile(
                            collapsedIconColor: Colors.white,
                            iconColor: Colors.lightBlue,
                            // backgroundColor: Colors.black.withOpacity(0.8),
                            leading:
                                const Icon(Icons.business, color: Colors.white),
                            title: Text(
                              'Company: $companyName',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            children: [
                              ListTile(
                                title: const Text(
                                  'View Financial Report',
                                  style: TextStyle(color: Colors.lightBlue),
                                ),
                                trailing: const Icon(
                                  Icons.insert_chart_outlined,
                                  color: Colors.lightBlue,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FinancialManagementReport(
                                              companyId: companyId),
                                    ),
                                  );
                                },
                              ),
                              ...reports.map((report) {
                                return ListTile(
                                  title: Text(
                                    report.discription,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    'Amount: ${report.totalAmount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final shouldDelete =
                                          await showDeleteDialog(context);
                                      if (shouldDelete) {
                                        await _rentService
                                            .deleteFinancialReport(
                                                id: report.id);
                                      }
                                    },
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
                                          financialReport: report,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue, // Customize button color
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
