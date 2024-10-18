import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/rents/reports/generate_monthly_report.dart';

class GenerateRentReport extends StatelessWidget {
  final String companyId;
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();

  GenerateRentReport({super.key, required this.companyId});

  Future<List<Map<String, dynamic>>> _fetchRentsWithDetails() async {
    final rents = await _rentService.getRentsByCompanyId(companyId: companyId);
    List<Map<String, dynamic>> rentDetailsList = [];

    for (var rent in rents) {
      if (rent.endContract != 'Contract_Ended') {
        final property =
            await _propertyService.getProperty(id: rent.propertyId);
        final profile = await _rentService.getProfile(id: rent.profileId);

        final payments = rent.paymentStatus.split('; ');
        final firstPaymentDate =
            payments.isNotEmpty ? payments.last.split(', ')[3] : '';
        final lastAdvancePayment =
            payments.isNotEmpty ? payments.last.split(', ')[1] : '';

        rentDetailsList.add({
          'rent': rent,
          'property': property,
          'profile': profile,
          'firstPaymentDate': firstPaymentDate,
          'lastAdvancePayment': lastAdvancePayment,
          'paymentStatus': rent.paymentStatus, // Add paymentStatus here
        });
      }
    }

    return rentDetailsList;
  }

  Future<String> _fetchCompanyName() async {
    final company = await _rentService.getCompanyById(companyId: companyId);
    return company.companyName;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }
    }
  }

  Future<void> _generatePdf(BuildContext context,
      List<Map<String, dynamic>> rentDetailsList, String companyName) async {
    await _requestPermissions();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '$companyName Rent Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: [
              'No',
              'Property No.',
              'Floor No.',
              'Size (sqm)',
              'Rent Amount/month',
              'Contract',
              'Profile Name',
              'Payment Date ',
              'Advance Payment',
              'Next Payment',
              'Months Left',
            ],
            data: List<List<String>>.generate(
              rentDetailsList.length,
              (index) {
                final rentDetail = rentDetailsList[index];
                final rent = rentDetail['rent'] as CloudRent;
                final property = rentDetail['property'] as CloudProperty;
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
                  firstPaymentDate,
                  lastAdvancePayment,
                  rent.dueDate,
                  monthsLeft.toString(),
                  '${profile.firstName} ${profile.lastName}',
                ];
              },
            ),
          ),
        ],
      ),
    );

    final output = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getTemporaryDirectory();
    final file = File('${output!.path}/rent_report.pdf');
    await file.writeAsBytes(await pdf.save());

    final result = await OpenFile.open(file.path);

    if (result.type != ResultType.done) {
      if (context.mounted) {
        showErrorDialog(context, "Failed to open PDF: ${result.message}");
      }
    }
  }

  void _showPaymentStatusDialog(BuildContext context, String paymentStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(); // Close the dialog when tapped outside
          },
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            child: GestureDetector(
              onTap: () {}, // Prevent dialog from closing when tapped inside
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(),
                      _buildPaymentStatusTable(paymentStatus),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentStatusTable(String paymentStatus) {
    final rows = paymentStatus.split('; ');
    final headers = [
      'Payment Count',
      'Advance Payment',
      'Payment Type',
      'Payment Date',
      'Next Payment',
      'Payment Amount',
    ];

    return DataTable(
      border: TableBorder.all(color: Colors.black),
      columns: headers
          .map(
            (header) => DataColumn(
              label: Text(
                header,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
      rows: rows.map((row) {
        final cells = row.split(', ');
        final paddedCells = List<String>.from(cells);
        while (paddedCells.length < headers.length) {
          paddedCells.add('');
        }

        return DataRow(
          cells: paddedCells.map((cell) => DataCell(Text(cell))).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Report'),
      ),
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

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          border: TableBorder.all(
                            color: Colors.grey, // Border color
                            width: 1.5, // Border width
                          ),
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Property No')),
                            DataColumn(label: Text('Floor No')),
                            DataColumn(label: Text('Size (sqm)')),
                            DataColumn(label: Text('Rent Amount/month')),
                            DataColumn(label: Text('Contract')),
                            DataColumn(label: Text('Profile Name')),
                            DataColumn(label: Text('Payment Date ')),
                            DataColumn(label: Text('Advance Payment')),
                            DataColumn(label: Text('Next payment')),
                            DataColumn(label: Text('Months Left')),
                          ],
                          rows: List<DataRow>.generate(
                            rentDetailsList.length,
                            (index) {
                              final rentDetail = rentDetailsList[index];
                              final rent = rentDetail['rent'] as CloudRent;
                              final property =
                                  rentDetail['property'] as CloudProperty;
                              final profile =
                                  rentDetail['profile'] as CloudProfile;
                              final firstPaymentDate =
                                  rentDetail['firstPaymentDate'];
                              final lastAdvancePayment =
                                  rentDetail['lastAdvancePayment'];
                              final DateTime dueDate =
                                  DateTime.parse(rent.dueDate);
                              final monthsLeft =
                                  dueDate.difference(DateTime.now()).inDays ~/
                                      30;

                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(property.propertyNumber)),
                                  DataCell(Text(property.floorNumber)),
                                  DataCell(Text(property.sizeInSquareMeters)),
                                  DataCell(Text(rent.rentAmount.toString())),
                                  DataCell(Text(rent.contract)),
                                  DataCell(Text(
                                      '${profile.firstName} ${profile.lastName}')),
                                  DataCell(Text(firstPaymentDate)),
                                  DataCell(Text(lastAdvancePayment)),
                                  DataCell(Text(rent.dueDate)),
                                  DataCell(Text(monthsLeft.toString())),
                                ],
                                onSelectChanged: (selected) {
                                  if (selected == true) {
                                    _showPaymentStatusDialog(
                                      context,
                                      rentDetail['paymentStatus'],
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final companyName = await _fetchCompanyName();
                            await _generatePdf(
                                context, rentDetailsList, companyName);
                          },
                          child: const Text('Generate PDF'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    GenerateMonthlyReport(companyId: companyId),
              ),
            );
          }
        },
        icon: const Icon(Icons.report),
        label: const Text('Monthly Report'),
        tooltip: 'Generate Monthly Report',
      ),
    );
  }
}
