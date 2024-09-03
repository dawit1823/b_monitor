import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';
import 'package:intl/intl.dart';

class FinancialManagementReport extends StatefulWidget {
  final String companyId;

  const FinancialManagementReport({super.key, required this.companyId});

  @override
  State<FinancialManagementReport> createState() =>
      _FinancialManagementReportState();
}

class _FinancialManagementReportState extends State<FinancialManagementReport> {
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
    final currentUserId = AuthService.firebase().currentUser!.id;
    final reports =
        await _rentService.allFinancialReports(creatorId: currentUserId).first;
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
          return txnDate.isAfter(_selectedStartDate!) &&
              txnDate.isBefore(_selectedEndDate!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Management Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredReports.isEmpty
              ? const Center(
                  child: Text('No financial reports found for this company'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Transaction Type')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Total Amount')),
                      DataColumn(label: Text('Transaction Date')),
                    ],
                    rows: _filteredReports.map((report) {
                      return DataRow(cells: [
                        DataCell(Text(report.txnType)),
                        DataCell(Text(report.discription)),
                        DataCell(Text(report.totalAmount)),
                        DataCell(Text(report.txnDate)),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}
