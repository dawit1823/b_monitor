// generate_rent_report.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'generate_monthly_report.dart';

class GenerateRentReport extends StatelessWidget {
  final String companyId;
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();

  GenerateRentReport({Key? key, required this.companyId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchRentsWithDetails() async {
    final rents = await _rentService.getRentsByCompanyId(companyId: companyId);
    List<Map<String, dynamic>> rentDetailsList = [];

    for (var rent in rents) {
      if (rent.endContract != 'Contract_Ended') {
        final property =
            await _propertyService.getProperty(id: rent.propertyId);
        final profile = await _rentService.getProfile(id: rent.profileId);

        // Parse payment status
        final payments = rent.paymentStatus.split('; ');
        final firstPaymentDate =
            payments.isNotEmpty ? payments.first.split(', ')[3] : '';
        final lastAdvancePayment =
            payments.isNotEmpty ? payments.last.split(', ')[1] : '';

        rentDetailsList.add({
          'rent': rent,
          'property': property,
          'profile': profile,
          'firstPaymentDate': firstPaymentDate,
          'lastAdvancePayment': lastAdvancePayment,
        });
      }
    }

    return rentDetailsList;
  }

  Future<String> _fetchCompanyName() async {
    final company = await _rentService.getCompanyById(companyId: companyId);
    return company.companyName;
  }

  Future<void> _generatePdf(
      List<Map<String, dynamic>> rentDetailsList, String companyName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape, // Changed to landscape
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '$companyName Rent Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Table.fromTextArray(
            headers: [
              'No',
              'Property No',
              'Floor No',
              'Size (sqm)',
              'Rent Amount',
              'Contract',
              'Due Date',
              'Months Left',
              'Profile Name',
              'Payment Date (1st)',
              'Advance Payment (Last)',
            ],
            data: List<List<String>>.generate(
              rentDetailsList.length,
              (index) {
                final rentDetail = rentDetailsList[index];
                final rent = rentDetail['rent'] as CloudRent;
                final property = rentDetail['property'] as DatabaseProperty;
                final profile = rentDetail['profile'] as CloudProfile;
                final firstPaymentDate = rentDetail['firstPaymentDate'];
                final lastAdvancePayment = rentDetail['lastAdvancePayment'];
                final DateTime dueDate = DateTime.parse(rent.dueDate);
                final monthsLeft =
                    dueDate.difference(DateTime.now()).inDays ~/ 30;

                return [
                  (index + 1).toString(),
                  property.propertyNumber,
                  property.floorNumber,
                  property.sizeInSquareMeters,
                  rent.rentAmount.toString(),
                  rent.contract,
                  rent.dueDate,
                  monthsLeft.toString(),
                  '${profile.firstName} ${profile.lastName}',
                  firstPaymentDate,
                  lastAdvancePayment,
                ];
              },
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/rent_report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the saved PDF file
    final result = await OpenFile.open(file.path);

    // Handle result if needed (e.g., show an error message if opening failed)
    if (result.type != ResultType.done) {
      print("Failed to open PDF: ${result.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent Report')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRentsWithDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          } else {
            final rentDetailsList = snapshot.data!;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Property No')),
                      DataColumn(label: Text('Floor No')),
                      DataColumn(label: Text('Size (sqm)')),
                      DataColumn(label: Text('Rent Amount')),
                      DataColumn(label: Text('Contract')),
                      DataColumn(label: Text('Due Date')),
                      DataColumn(label: Text('Months Left')),
                      DataColumn(label: Text('Profile Name')),
                      DataColumn(label: Text('Payment Date (1st)')),
                      DataColumn(label: Text('Advance Payment (Last)')),
                    ],
                    rows:
                        List<DataRow>.generate(rentDetailsList.length, (index) {
                      final rentDetail = rentDetailsList[index];
                      final rent = rentDetail['rent'] as CloudRent;
                      final property =
                          rentDetail['property'] as DatabaseProperty;
                      final profile = rentDetail['profile'] as CloudProfile;
                      final firstPaymentDate = rentDetail['firstPaymentDate'];
                      final lastAdvancePayment =
                          rentDetail['lastAdvancePayment'];
                      final DateTime dueDate = DateTime.parse(rent.dueDate);
                      final monthsLeft =
                          dueDate.difference(DateTime.now()).inDays ~/ 30;

                      return DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(property.propertyNumber)),
                          DataCell(Text(property.floorNumber)),
                          DataCell(Text(property.sizeInSquareMeters)),
                          DataCell(Text(rent.rentAmount.toString())),
                          DataCell(Text(rent.contract)),
                          DataCell(Text(rent.dueDate)),
                          DataCell(Text(monthsLeft.toString())),
                          DataCell(
                              Text('${profile.firstName} ${profile.lastName}')),
                          DataCell(Text(firstPaymentDate)),
                          DataCell(Text(lastAdvancePayment)),
                        ],
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (monthsLeft == 1) return Colors.yellow;
                            return null; // Use default color
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Fetch the company name for the header
                      final companyName = await _fetchCompanyName();
                      await _generatePdf(rentDetailsList, companyName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF saved successfully.')),
                      );
                    },
                    child: Text('Print'),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GenerateMonthlyReport(companyId: companyId),
            ),
          );
        },
        child: Icon(Icons.report),
        tooltip: 'Generate Monthly Report',
      ),
    );
  }
}
