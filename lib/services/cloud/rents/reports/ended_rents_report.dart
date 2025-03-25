import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';

class EndedRentsReport extends StatefulWidget {
  final String companyId;

  const EndedRentsReport({super.key, required this.companyId});

  @override
  State<EndedRentsReport> createState() => _EndedRentsReportState();
}

class _EndedRentsReportState extends State<EndedRentsReport> {
  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  List<Map<String, dynamic>> _rentDetailsList = [];
  List<Map<String, dynamic>> _filteredRentDetailsList = [];
  String _sortBy = 'profile.companyName';
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchEndedRentsWithDetails();
  }

  Future<void> _fetchEndedRentsWithDetails() async {
    setState(() {
      _isLoading = true;
    });

    final rents =
        await _rentService.getRentsByCompanyId(companyId: widget.companyId);
    List<Map<String, dynamic>> rentDetailsList = [];

    for (var rent in rents) {
      if (rent.endContract == 'Contract_Ended') {
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
          'contractEndedDate':
              rent.dueDate, // Using dueDate as contract ended date
        });
      }
    }

    setState(() {
      _rentDetailsList = rentDetailsList;
      _filteredRentDetailsList = List.from(_rentDetailsList);
      _sortRentDetails();
      _isLoading = false;
    });
  }

  void _filterByDateRange() {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _filteredRentDetailsList = List.from(_rentDetailsList);
      });
      return;
    }

    setState(() {
      _filteredRentDetailsList = _rentDetailsList.where((rentDetail) {
        final rent = rentDetail['rent'] as CloudRent;
        final endedDate = DateTime.parse(rent.dueDate);
        return endedDate.isAfter(_startDate!) && endedDate.isBefore(_endDate!);
      }).toList();
    });
  }

  void _sortRentDetails() {
    switch (_sortBy) {
      case 'profile.companyName':
        _filteredRentDetailsList.sort((a, b) => (a['profile'] as CloudProfile)
            .companyName
            .compareTo((b['profile'] as CloudProfile).companyName));
        break;
      case 'propertyNumber':
        _filteredRentDetailsList.sort((a, b) => (a['property'] as CloudProperty)
            .propertyNumber
            .compareTo((b['property'] as CloudProperty).propertyNumber));
        break;
      case 'floorNumber':
        _filteredRentDetailsList.sort((a, b) => (a['property'] as CloudProperty)
            .floorNumber
            .compareTo((b['property'] as CloudProperty).floorNumber));
        break;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _filterByDateRange();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _filterByDateRange();
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
              '$companyName Ended Contracts Rent Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (_startDate != null && _endDate != null)
            pw.Paragraph(
              text:
                  'Date Range: ${_dateFormat.format(_startDate!)} to ${_dateFormat.format(_endDate!)}',
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
              'Payment Date',
              'Advance Payment',
              'Contract Ended Date',
            ],
            data: List<List<String>>.generate(
              _filteredRentDetailsList.length,
              (index) {
                final rentDetail = _filteredRentDetailsList[index];
                final rent = rentDetail['rent'] as CloudRent;
                final property = rentDetail['property'] as CloudProperty;
                final profile = rentDetail['profile'] as CloudProfile;
                final firstPaymentDate = rentDetail['firstPaymentDate'];
                final lastAdvancePayment = rentDetail['lastAdvancePayment'];

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
    final file = File('${output!.path}/ended_rents_report.pdf');
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
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
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
        title: const Text('Ended Contracts Rent Report'),
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
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectStartDate(context),
                          child: Text(
                            _startDate == null
                                ? 'Select Start Date'
                                : 'Start: ${_dateFormat.format(_startDate!)}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _selectEndDate(context),
                          child: Text(
                            _endDate == null
                                ? 'Select End Date'
                                : 'End: ${_dateFormat.format(_endDate!)}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _filteredRentDetailsList =
                                  List.from(_rentDetailsList);
                            });
                          },
                          child: const Text('Clear Filter'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredRentDetailsList.isEmpty
                      ? const Center(
                          child: Text(
                            'No ended contracts found for the selected date range',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              border: TableBorder.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              columns: const [
                                DataColumn(label: Text('No')),
                                DataColumn(label: Text('Profile Name')),
                                DataColumn(label: Text('Property No')),
                                DataColumn(label: Text('Floor No')),
                                DataColumn(label: Text('Size (sqm)')),
                                DataColumn(label: Text('Rent Amount/month')),
                                DataColumn(label: Text('Contract')),
                                DataColumn(label: Text('Payment Date')),
                                DataColumn(label: Text('Advance Payment')),
                                DataColumn(label: Text('Contract Ended Date')),
                              ],
                              rows: List<DataRow>.generate(
                                _filteredRentDetailsList.length,
                                (index) {
                                  final rentDetail =
                                      _filteredRentDetailsList[index];
                                  final profile =
                                      rentDetail['profile'] as CloudProfile;
                                  final rent = rentDetail['rent'] as CloudRent;
                                  final property =
                                      rentDetail['property'] as CloudProperty;
                                  final firstPaymentDate =
                                      rentDetail['firstPaymentDate'];
                                  final lastAdvancePayment =
                                      rentDetail['lastAdvancePayment'];

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
                                    ],
                                    onSelectChanged: (selected) {
                                      if (selected == true) {
                                        _showPaymentStatusDialog(context,
                                            rentDetail['paymentStatus']);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final companyName = await _fetchCompanyName();
          if (context.mounted) {
            await _generatePdf(context, companyName);
          }
        },
        tooltip: 'Generate PDF',
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
