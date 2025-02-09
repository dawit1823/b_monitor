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
import 'package:r_and_e_monitor/services/cloud/rents/reports/ended_rents_report.dart';
import 'package:r_and_e_monitor/services/cloud/rents/reports/generate_monthly_report.dart';

class GenerateRentReport extends StatefulWidget {
  final String companyId;

  const GenerateRentReport({super.key, required this.companyId});

  @override
  State<GenerateRentReport> createState() => _GenerateRentReportState();
}

class _GenerateRentReportState extends State<GenerateRentReport> {
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  List<Map<String, dynamic>> _rentDetailsList = [];
  String _sortBy = 'profile.companyName';
  bool _isLoading = true;
  bool _hasEndedContracts = false;
  bool _hasAnyContracts =
      false; // New variable to track any contracts existence

  @override
  void initState() {
    super.initState();
    _fetchRentsWithDetails();
  }

  Future<void> _fetchRentsWithDetails() async {
    setState(() {
      _isLoading = true;
      _hasEndedContracts = false;
      _hasAnyContracts = false; // Reset flags
    });

    final rents =
        await _rentService.getRentsByCompanyId(companyId: widget.companyId);
    List<Map<String, dynamic>> rentDetailsList = [];
    bool hasEnded = false;
    bool hasAny = rents.isNotEmpty; // Check if any contracts exist

    for (var rent in rents) {
      if (rent.endContract == 'Contract_Ended') {
        hasEnded = true;
      } else {
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
          'paymentStatus': rent.paymentStatus,
        });
      }
    }

    setState(() {
      _rentDetailsList = rentDetailsList;
      _hasEndedContracts = hasEnded;
      _hasAnyContracts = hasAny; // Update based on any contracts existence
      _sortRentDetails();
      _isLoading = false;
    });
  }

  void _sortRentDetails() {
    switch (_sortBy) {
      case 'profile.companyName':
        _rentDetailsList.sort((a, b) => (a['profile'] as CloudProfile)
            .companyName
            .compareTo((b['profile'] as CloudProfile).companyName));
        break;
      case 'propertyNumber':
        _rentDetailsList.sort((a, b) => (a['property'] as CloudProperty)
            .propertyNumber
            .compareTo((b['property'] as CloudProperty).propertyNumber));
        break;
      case 'floorNumber':
        _rentDetailsList.sort((a, b) => (a['property'] as CloudProperty)
            .floorNumber
            .compareTo((b['property'] as CloudProperty).floorNumber));
        break;
      case 'monthsLeft':
        _rentDetailsList.sort((a, b) {
          final rentA = a['rent'] as CloudRent;
          final rentB = b['rent'] as CloudRent;
          final monthsLeftA =
              DateTime.parse(rentA.dueDate).difference(DateTime.now()).inDays ~/
                  30;
          final monthsLeftB =
              DateTime.parse(rentB.dueDate).difference(DateTime.now()).inDays ~/
                  30;
          return monthsLeftA.compareTo(monthsLeftB);
        });
        break;
    }
  }

  Future<String> _fetchCompanyName() async {
    final company =
        await _rentService.getCompanyById(companyId: widget.companyId);
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

  Future<void> _generatePdf(BuildContext context, String companyName) async {
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
              'Profile Name',
              'Property No.',
              'Floor No.',
              'Size (sqm)',
              'Rent Amount/month',
              'Contract',
              'Paid On ',
              'Advance Payment',
              'Next Payment',
              'Months Left',
            ],
            data: List<List<String>>.generate(
              _rentDetailsList.length,
              (index) {
                final rentDetail = _rentDetailsList[index];
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
                  '${profile.companyName} / ${profile.firstName}',
                  property.propertyNumber,
                  property.floorNumber,
                  property.sizeInSquareMeters,
                  rent.rentAmount.toString(),
                  rent.contract,
                  firstPaymentDate,
                  lastAdvancePayment,
                  rent.dueDate,
                  monthsLeft.toString(),
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
            Navigator.of(context).pop();
          },
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            child: GestureDetector(
              onTap: () {},
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
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
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
      'Paid On',
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
          cells: paddedCells
              .map((cell) => DataCell(Text(
                    cell,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )))
              .toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Report'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (String newValue) {
              setState(() {
                _sortBy = newValue;
                _sortRentDetails();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile.companyName',
                child: Text('Profile Name'),
              ),
              const PopupMenuItem<String>(
                value: 'propertyNumber',
                child: Text('Property Number'),
              ),
              const PopupMenuItem<String>(
                value: 'floorNumber',
                child: Text('Floor Number'),
              ),
              const PopupMenuItem<String>(
                value: 'monthsLeft',
                child: Text('Months Left'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasAnyContracts // Check if any contracts exist (active or ended)
              ? LayoutBuilder(
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
                                  color: Colors.black, width: 1.5),
                              columns: const [
                                DataColumn(label: Text('No')),
                                DataColumn(label: Text('Profile Name')),
                                DataColumn(label: Text('Property No')),
                                DataColumn(label: Text('Floor No')),
                                DataColumn(label: Text('Size (sqm)')),
                                DataColumn(label: Text('Rent Amount/month')),
                                DataColumn(label: Text('Contract')),
                                DataColumn(label: Text('Paid On ')),
                                DataColumn(label: Text('Advance Payment')),
                                DataColumn(label: Text('Next payment')),
                                DataColumn(label: Text('Months Left')),
                              ],
                              rows: List<DataRow>.generate(
                                _rentDetailsList.length,
                                (index) {
                                  final rentDetail = _rentDetailsList[index];
                                  final profile =
                                      rentDetail['profile'] as CloudProfile;
                                  final rent = rentDetail['rent'] as CloudRent;
                                  final property =
                                      rentDetail['property'] as CloudProperty;

                                  final firstPaymentDate =
                                      rentDetail['firstPaymentDate'];
                                  final lastAdvancePayment =
                                      rentDetail['lastAdvancePayment'];
                                  final DateTime dueDate =
                                      DateTime.parse(rent.dueDate);
                                  final monthsLeft = dueDate
                                          .difference(DateTime.now())
                                          .inDays ~/
                                      30;

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                        (index + 1).toString(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        '${profile.companyName} / ${profile.firstName}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        property.propertyNumber,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        property.floorNumber,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        property.sizeInSquareMeters,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        rent.rentAmount.toString(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        rent.contract,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        firstPaymentDate,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        lastAdvancePayment,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        rent.dueDate,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
                                      DataCell(Text(
                                        monthsLeft.toString(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      )),
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final companyName =
                                        await _fetchCompanyName();
                                    if (context.mounted) {
                                      await _generatePdf(context, companyName);
                                    }
                                  },
                                  child: const Text('Generate PDF'),
                                ),
                                const SizedBox(height: 10),
                                if (_hasEndedContracts)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EndedRentsReport(
                                                    companyId:
                                                        widget.companyId),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      child: const Text(
                                          'View Ended Contract Report'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'There are no rents to display', // Consider updating message text
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    GenerateMonthlyReport(companyId: widget.companyId),
              ),
            );
          }
        },
        backgroundColor: Colors.lightBlue,
        icon: const Icon(Icons.report, color: Colors.black),
        label:
            const Text('Monthly Report', style: TextStyle(color: Colors.white)),
        tooltip: 'Generate Monthly Report',
      ),
    );
  }
}
