import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/reports/create_or_update_report_view.dart';
import '../employee_services/cloud_rent_service.dart';
import 'generate_report.dart';

class ReportViewPage extends StatelessWidget {
  final String rentId;
  final RentService _rentService = RentService();

  ReportViewPage({super.key, required this.rentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<Iterable<CloudReports>>(
        stream: _rentService.allReports(rentId: rentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reports found'));
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports.elementAt(index);
                return ListTile(
                  title: Text(report.reportTitle),
                  subtitle: Text(report.reportDate),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrUpdateReportView(
                          rentId: rentId,
                          companyId: report.companyId,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      try {
                        final rent = await _rentService.getRent(id: rentId);
                        final profile =
                            await _rentService.getProfile(id: rent.profileId);
                        final company =
                            await _rentService.getCompany(id: rent.companyId);
                        await generateAndPrintReport(
                            rent, profile, report, company);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to generate report: $e')),
                        );
                      }
                    },
                  ),
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
              builder: (context) => CreateOrUpdateReportView(
                rentId: rentId,
                companyId:
                    '', // or get the companyId from another source if needed
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
