import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/reports/create_or_update_report_view.dart';
import '../services/cloud_rent_service.dart';
import 'generate_report.dart';

class ReportViewPage extends StatelessWidget {
  final String rentId;
  final RentService _rentService = RentService();

  ReportViewPage({Key? key, required this.rentId}) : super(key: key);

  Future<CloudProfile> _fetchProfile(String rentId) async {
    final rent = await _rentService.getRent(id: rentId);
    return await _rentService.getProfile(id: rent.profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Reports')),
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
                        builder: (context) =>
                            CreateOrUpdateReportView(rentId: rentId),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () async {
                      final rent = await _rentService.getRent(id: rentId);
                      final profile =
                          await _rentService.getProfile(id: rent.profileId);
                      await generateAndPrintReport(rent, profile, report);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
