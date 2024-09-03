//generate_monthly_report.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/generic_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';

class GenerateMonthlyReport extends StatefulWidget {
  final String companyId;

  const GenerateMonthlyReport({super.key, required this.companyId});

  @override
  GenerateMonthlyReportState createState() => GenerateMonthlyReportState();
}

class GenerateMonthlyReportState extends State<GenerateMonthlyReport> {
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  DateTimeRange? selectedDateRange;

  Future<List<Map<String, dynamic>>> _fetchRentsWithDetails() async {
    final rents =
        await _rentService.getRentsByCompanyId(companyId: widget.companyId);
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
        final paymentDate = rent.paymentStatus.split(', ').length > 3
            ? rent.paymentStatus.split(', ')[3]
            : '';

        rentDetailsList.add({
          'rent': rent,
          'property': property,
          'profile': profile,
          'firstPaymentDate': firstPaymentDate,
          'lastAdvancePayment': lastAdvancePayment,
          'paymentDate': paymentDate,
        });
      }
    }

    return rentDetailsList;
  }

  List<Map<String, dynamic>> _filterRentsByDateRange(
      List<Map<String, dynamic>> rentDetails, DateTimeRange dateRange) {
    return rentDetails.where((rentDetail) {
      final paymentDate = DateTime.parse(rentDetail['paymentDate']);
      return paymentDate.isAfter(dateRange.start) &&
          paymentDate.isBefore(dateRange.end);
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange ??
          DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (!mounted) return; // Guard against widget dismount

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  Future<void> _generatePdf(
      List<Map<String, dynamic>> rentDetailsList, String companyName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '$companyName Monthly Rent Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: [
              'No',
              'Property No',
              'Floor No',
              'Profile Name',
              'Rent Amount',
              'Payment Type',
              'Deposited On',
              'Advance Payment',
              'Payment Date',
            ],
            data: List<List<String>>.generate(
              rentDetailsList.length,
              (index) {
                final rentDetail = rentDetailsList[index];
                final property = rentDetail['property'] as CloudProperty;
                final profile = rentDetail['profile'] as CloudProfile;
                final rent = rentDetail['rent'] as CloudRent;
                final paymentDate = rentDetail['paymentDate'];

                return [
                  (index + 1).toString(),
                  property.propertyNumber,
                  property.floorNumber,
                  '${profile.firstName} ${profile.lastName}',
                  rent.rentAmount.toString(),
                  rent.paymentStatus.split(', ')[2],
                  rent.paymentStatus.split(', ')[4],
                  rent.paymentStatus.split(', ')[1],
                  paymentDate,
                ];
              },
            ),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/monthly_rent_report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Guard against widget dismount

    final result = await OpenFile.open(file.path);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      // Show error dialog instead of printing in production
      await showGenericDialog(
        context: context,
        title: "Error",
        content: "Failed to open PDF: ${result.message}",
        optionBuilder: () => {
          'OK': null,
        },
      );
    }
  }

  Future<String> _fetchCompanyName() async {
    final company =
        await _rentService.getCompanyById(companyId: widget.companyId);
    return company.companyName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Monthly Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectDateRange, // No longer passing context
              child: const Text('Select Date Range'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRentsWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found'));
                } else {
                  final rentDetailsList = selectedDateRange != null
                      ? _filterRentsByDateRange(
                          snapshot.data!, selectedDateRange!)
                      : snapshot.data!;

                  double totalRentAmount =
                      rentDetailsList.fold(0.0, (sum, rentDetail) {
                    final rent = rentDetail['rent'] as CloudRent;
                    return sum + rent.rentAmount;
                  });

                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Property No')),
                            DataColumn(label: Text('Floor No')),
                            DataColumn(label: Text('Profile Name')),
                            DataColumn(label: Text('Rent Amount')),
                            DataColumn(label: Text('Payment Type')),
                            DataColumn(label: Text('Deposited On')),
                            DataColumn(label: Text('Advance Payment')),
                            DataColumn(label: Text('Payment Date')),
                          ],
                          rows: List<DataRow>.generate(rentDetailsList.length,
                              (index) {
                            final rentDetail = rentDetailsList[index];
                            final rent = rentDetail['rent'] as CloudRent;
                            final property =
                                rentDetail['property'] as CloudProperty;
                            final profile =
                                rentDetail['profile'] as CloudProfile;
                            final paymentDate = rentDetail['paymentDate'];

                            return DataRow(
                              cells: [
                                DataCell(Text((index + 1).toString())),
                                DataCell(Text(property.propertyNumber)),
                                DataCell(Text(property.floorNumber)),
                                DataCell(Text(
                                    '${profile.firstName} ${profile.lastName}')),
                                DataCell(Text(rent.rentAmount.toString())),
                                DataCell(
                                    Text(rent.paymentStatus.split(', ')[2])),
                                DataCell(
                                    Text(rent.paymentStatus.split(', ')[4])),
                                DataCell(
                                    Text(rent.paymentStatus.split(', ')[1])),
                                DataCell(Text(paymentDate)),
                              ],
                            );
                          })
                            ..add(DataRow(
                              cells: [
                                const DataCell(Text('Total',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                DataCell(Text(totalRentAmount.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                              ],
                            )),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final companyName = await _fetchCompanyName();
                          await _generatePdf(rentDetailsList, companyName);

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('PDF saved successfully.')),
                          );
                        },
                        child: const Text('Print Report'),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
