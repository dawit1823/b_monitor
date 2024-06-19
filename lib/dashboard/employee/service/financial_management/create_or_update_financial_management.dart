// create_or_update_financial_management.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';

class CreateOrUpdateFinancialManagement extends StatefulWidget {
  final CloudFinancialManagement? report;
  final String creatorId;
  final String companyId;

  const CreateOrUpdateFinancialManagement({
    Key? key,
    this.report,
    required this.creatorId,
    required this.companyId,
  }) : super(key: key);

  @override
  _CreateOrUpdateFinancialManagementState createState() =>
      _CreateOrUpdateFinancialManagementState();
}

class _CreateOrUpdateFinancialManagementState
    extends State<CreateOrUpdateFinancialManagement> {
  final TextEditingController _txnTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _txnDateController = TextEditingController();
  final RentService _rentService = RentService();

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _txnTypeController.text = widget.report!.txnType;
      _descriptionController.text = widget.report!.discription;
      _totalAmountController.text = widget.report!.totalAmount;
      _txnDateController.text = widget.report!.txnDate;
    }
  }

  @override
  void dispose() {
    _txnTypeController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _txnDateController.dispose();
    super.dispose();
  }

  Future<void> _saveFinancialReport() async {
    final txnType = _txnTypeController.text.trim();
    final description = _descriptionController.text.trim();
    final totalAmount = _totalAmountController.text.trim();
    final txnDate = _txnDateController.text.trim();

    if (widget.report == null) {
      await _rentService.createFinancialReport(
        creatorId: widget.creatorId,
        companyId: widget.companyId,
        txnType: txnType,
        discription: description,
        totalAmount: totalAmount,
        txnDate: txnDate,
      );
    } else {
      await _rentService.updateFinancialReport(
        id: widget.report!.id,
        txnType: txnType,
        discription: description,
        totalAmount: totalAmount,
        txnDate: txnDate,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null
            ? 'Create Financial Report'
            : 'Update Financial Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _txnTypeController,
              decoration: const InputDecoration(labelText: 'Transaction Type'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _totalAmountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _txnDateController,
              decoration: const InputDecoration(labelText: 'Transaction Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFinancialReport,
              child: Text(widget.report == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
