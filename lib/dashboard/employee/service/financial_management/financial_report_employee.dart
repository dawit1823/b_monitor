import 'package:flutter/material.dart';
import '../../../../services/cloud/cloud_data_models.dart';
import '../../../../services/cloud/employee_services/cloud_rent_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FinancialManagementReportEmployee extends StatefulWidget {
  final String creatorId;
  final String companyId;

  const FinancialManagementReportEmployee({
    super.key,
    required this.creatorId,
    required this.companyId,
  });

  @override
  State<FinancialManagementReportEmployee> createState() =>
      _FinancialManagementReportEmployeeState();
}

class _FinancialManagementReportEmployeeState
    extends State<FinancialManagementReportEmployee> {
  final RentService _rentService = RentService();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<CloudFinancialManagement> _filteredReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialReports();
  }

  Future<void> _loadFinancialReports() async {
    final reports = await _rentService
        .allFinancialReports(creatorId: widget.creatorId)
        .first;

    setState(() {
      _filteredReports = reports
          .where((report) => report.companyId == widget.companyId)
          .toList();
      _isLoading = false;
    });
  }

  void _filterReportsByDate() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      setState(() {
        _filteredReports = _filteredReports.where((report) {
          final txnDate = DateFormat('yyyy-MM-dd').parse(report.txnDate);
          return (txnDate.isAfter(_selectedStartDate!) ||
                  txnDate.isAtSameMomentAs(_selectedStartDate!)) &&
              (txnDate.isBefore(_selectedEndDate!) ||
                  txnDate.isAtSameMomentAs(_selectedEndDate!));
        }).toList();
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _selectedStartDate ?? DateTime.now(),
        end: _selectedEndDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _filterReportsByDate();
    }
  }

  double _calculateSubTotal() {
    return _filteredReports.fold(
      0.0,
      (sum, report) => sum + double.tryParse(report.totalAmount)!,
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    String month = _selectedStartDate != null
        ? '${DateFormat('MMMM-dd').format(_selectedStartDate!)}  -  ${DateFormat('MMMM-dd').format(_selectedEndDate!)}'
        : 'All Time';
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Financial Report $month',
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.TableHelper.fromTextArray(
                headers: [
                  'No',
                  'Transaction Type',
                  'Description',
                  'Amount',
                  'Transaction Date'
                ],
                data: [
                  ..._filteredReports.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    var report = entry.value;
                    return [
                      index,
                      report.txnType,
                      report.discription,
                      report.totalAmount,
                      report.txnDate
                    ];
                  }).toList(),
                  [
                    'SubTotal',
                    '',
                    '',
                    '\$${_calculateSubTotal().toStringAsFixed(2)}',
                    ''
                  ],
                  [
                    'VAT (15%)',
                    '',
                    '',
                    '\$${(_calculateSubTotal() * 0.15).toStringAsFixed(2)}',
                    ''
                  ],
                  [
                    'Total',
                    '',
                    '',
                    '\$${(_calculateSubTotal() * 1.15).toStringAsFixed(2)}',
                    ''
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final subTotal = _calculateSubTotal();
    final vat = subTotal * 0.15;
    final totalAmount = subTotal + vat;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        title: Row(
          children: [
            const Icon(Icons.pie_chart, size: 28),
            const SizedBox(width: 8),
            // Wrap the Text widget with Expanded to prevent overflow
            const Expanded(
              child: Text(
                'Financial Management Report',
                overflow: TextOverflow
                    .ellipsis, // This will add '...' if text is too long
                selectionColor: Color.fromARGB(255, 66, 143, 107),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _generatePDF,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.report, size: 100, color: Colors.black),
                      SizedBox(height: 16),
                      Text('No financial reports found.',
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  border: TableBorder.all(),
                                  headingRowColor: WidgetStateProperty.all(
                                      const Color.fromARGB(255, 213, 237, 179)),
                                  columns: const [
                                    DataColumn(label: Text('No.')),
                                    DataColumn(label: Text('Transaction Type')),
                                    DataColumn(label: Text('Description')),
                                    DataColumn(label: Text('Amount')),
                                    DataColumn(label: Text('Transaction Date')),
                                  ],
                                  rows: [
                                    ..._filteredReports
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key + 1;
                                      var report = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(index.toString())),
                                          DataCell(Text(report.txnType)),
                                          DataCell(Text(report.discription)),
                                          DataCell(Text(report.totalAmount)),
                                          DataCell(Text(report.txnDate)),
                                        ],
                                      );
                                    }).toList(),
                                    DataRow(cells: [
                                      DataCell(
                                        Text('SubTotal',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      const DataCell(Text('')),
                                      const DataCell(Text('')),
                                      DataCell(
                                        Text('\$${subTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            selectionColor: Colors.black),
                                      ),
                                      const DataCell(Text('')),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                        Text('VAT (15%)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            selectionColor: Colors.black),
                                      ),
                                      const DataCell(Text('')),
                                      const DataCell(Text('')),
                                      DataCell(
                                        Text('\$${vat.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            selectionColor: Colors.black),
                                      ),
                                      const DataCell(Text('')),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(
                                        Text('Total Amount',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ),
                                      const DataCell(Text('')),
                                      const DataCell(Text('')),
                                      DataCell(
                                        Text(
                                            '\$${totalAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            selectionColor: Colors.black),
                                      ),
                                      const DataCell(Text('')),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Summary',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    selectionColor: Colors.black,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          'SubTotal: \$${subTotal.toStringAsFixed(2)}'),
                                      Text(
                                          'VAT (15%): \$${vat.toStringAsFixed(2)}'),
                                      Text(
                                        'Total: \$${totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        selectionColor: Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
