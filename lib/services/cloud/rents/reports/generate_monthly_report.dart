// generate_monthly_report.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/generic_dialog.dart';
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
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    // Set default to current month
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    selectedDateRange = DateTimeRange(start: firstDay, end: lastDay);
  }

  Future<List<Map<String, dynamic>>> _fetchAllPayments() async {
    final rents =
        await _rentService.getRentsByCompanyId(companyId: widget.companyId);
    List<Map<String, dynamic>> allPayments = [];

    for (var rent in rents) {
      if (rent.endContract != 'Contract_Ended') {
        final property =
            await _propertyService.getProperty(id: rent.propertyId);
        final profile = await _rentService.getProfile(id: rent.profileId);

        final payments = rent.paymentStatus.split('; ');
        for (var payment in payments) {
          final components = payment.split(', ');
          if (components.length >= 6) {
            allPayments.add({
              'rent': rent,
              'property': property,
              'profile': profile,
              'paymentCount': components[0],
              'advancePayment': components[1],
              'paymentType': components[2],
              'paymentDate': components[3],
              'depositedOn': components[4],
              'paymentAmount': components[5],
            });
          }
        }
      }
    }
    return allPayments;
  }

  List<Map<String, dynamic>> _filterPaymentsByDateRange(
      List<Map<String, dynamic>> payments, DateTimeRange? dateRange) {
    if (dateRange == null) return payments;

    return payments.where((payment) {
      try {
        final paymentDate = DateTime.parse(payment['paymentDate']);
        return (paymentDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            paymentDate.isBefore(dateRange.end.add(const Duration(days: 1))));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
        context: context,
        initialDateRange: selectedDateRange,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.deepPurple, // Header color
              colorScheme: ColorScheme.light(
                  primary: Colors.deepPurple), // Selected dates
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        });

    if (picked != null && picked != selectedDateRange) {
      setState(() => selectedDateRange = picked);
    }
  }

  Future<void> _generatePdf(
      List<Map<String, dynamic>> payments, String companyName) async {
    final pdf = pw.Document();
    final filteredPayments =
        _filterPaymentsByDateRange(payments, selectedDateRange);

    // Calculate totals
    double totalRI = filteredPayments.fold(
        0.0,
        (sum, payment) =>
            sum +
            (double.tryParse(payment['paymentAmount'].replaceAll(',', '')) ??
                0.0));
    double vat = totalRI * 0.015;
    double total = totalRI + vat;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '$companyName Monthly Rent Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date Range: ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} to ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
            ],
          ),
          pw.TableHelper.fromTextArray(
            headers: [
              'No',
              'Profile',
              'Property',
              'Floor',
              'Size (sqm)',
              'Payment Type',
              'Payment Date',
              'Amount',
              'Advance Months',
            ],
            data: [
              ...filteredPayments.asMap().entries.map((e) {
                final index = e.key;
                final payment = e.value;
                return [
                  (index + 1).toString(),
                  payment['profile'].companyName,
                  payment['property'].propertyNumber,
                  payment['property'].floorNumber,
                  payment['property'].sizeInSquareMeters,
                  payment['paymentType'],
                  payment['paymentDate'],
                  payment['paymentAmount'],
                  payment['advancePayment'],
                ];
              }),
              [
                'Total RI:',
                '',
                '',
                '',
                '',
                '',
                _currencyFormat.format(totalRI)
              ],
              [
                'VAT (1.5%):',
                '',
                '',
                '',
                '',
                '',
                _currencyFormat.format(
                  vat,
                )
              ],
              ['Total:', '', '', '', '', '', _currencyFormat.format(total)],
            ],
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/monthly_rent_report.pdf');
    await file.writeAsBytes(await pdf.save());

    if (!mounted) return;
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      await showGenericDialog(
        context: context,
        title: "Error",
        content: "Failed to open PDF: ${result.message}",
        optionBuilder: () => {'OK': null},
      );
    }
  }

  Widget _buildDataTable(List<Map<String, dynamic>> payments) {
    final filteredPayments =
        _filterPaymentsByDateRange(payments, selectedDateRange);
    double totalRI = filteredPayments.fold(
        0.0,
        (sum, payment) =>
            sum +
            (double.tryParse(payment['paymentAmount'].replaceAll(',', '')) ??
                0.0));
    double vat = totalRI * 0.015;
    double total = totalRI + vat;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(), // Add table borders
        columns: const [
          DataColumn(label: Text('No', style: TextStyle(color: Colors.black))),
          DataColumn(
              label: Text('Profile', style: TextStyle(color: Colors.black))),
          DataColumn(
              label: Text('Property', style: TextStyle(color: Colors.black))),
          DataColumn(
              label: Text('Floor', style: TextStyle(color: Colors.black))),
          DataColumn(
              label: Text('Size (sqm)', style: TextStyle(color: Colors.black))),
          DataColumn(
              label:
                  Text('Payment Type', style: TextStyle(color: Colors.black))),
          DataColumn(
              label:
                  Text('Payment Date', style: TextStyle(color: Colors.black))),
          DataColumn(
              label: Text('Amount', style: TextStyle(color: Colors.black))),
          DataColumn(
              label: Text('Advance Months',
                  style: TextStyle(color: Colors.black))),
        ],
        rows: [
          ...filteredPayments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return DataRow(
              cells: [
                DataCell(Text(
                  (index + 1).toString(),
                  style: const TextStyle(color: Colors.black),
                )),
                DataCell(Text(payment['profile'].companyName,
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['property'].propertyNumber,
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['property'].floorNumber,
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['property'].sizeInSquareMeters,
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['paymentType'],
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['paymentDate'],
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['paymentAmount'],
                    style: const TextStyle(color: Colors.black))),
                DataCell(Text(payment['advancePayment'],
                    style: const TextStyle(color: Colors.black))),
              ],
            );
          }),
          DataRow(
            cells: [
              const DataCell(Text('Total RI:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))),
              DataCell(Text(_currencyFormat.format(totalRI),
                  style: const TextStyle(color: Colors.black))),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('VAT (1.5%):',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))),
              DataCell(Text(_currencyFormat.format(vat),
                  style: const TextStyle(color: Colors.black))),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
            ],
          ),
          DataRow(
            cells: [
              const DataCell(Text('Total:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))),
              DataCell(Text(_currencyFormat.format(total),
                  style: const TextStyle(color: Colors.black))),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
              const DataCell(Text('')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Financial Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectDateRange,
                    child: const Text('Select Date Range'),
                  ),
                  if (selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} '
                        'to ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAllPayments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.black)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No payment records found',
                          style: TextStyle(color: Colors.black)));
                }

                // Calculate totals here for both table and summary card
                final filteredPayments = _filterPaymentsByDateRange(
                    snapshot.data!, selectedDateRange);
                final totalRI = filteredPayments.fold(
                    0.0,
                    (sum, payment) =>
                        sum +
                        (double.tryParse(
                                payment['paymentAmount'].replaceAll(',', '')) ??
                            0.0));
                final vat = totalRI * 0.015;
                final total = totalRI + vat;

                return Column(
                  children: [
                    Expanded(child: _buildDataTable(filteredPayments)),
                    const SizedBox(height: 10),
                    Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Summary',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total RI: \$${_currencyFormat.format(totalRI)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  'VAT (1.5%): \$${_currencyFormat.format(vat)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  'Total: \$${_currencyFormat.format(total)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final company = await _rentService.getCompanyById(
                              companyId: widget.companyId);
                          await _generatePdf(
                              snapshot.data!, company.companyName);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('PDF generated successfully',
                                    style: TextStyle(color: Colors.black))),
                          );
                        },
                        child: const Text('Export to PDF'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
