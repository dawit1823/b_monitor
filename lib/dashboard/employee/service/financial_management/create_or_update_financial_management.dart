import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';

class CreateOrUpdateFinancialManagement extends StatefulWidget {
  final CloudFinancialManagement? report;
  final String creatorId;
  final String companyId;

  const CreateOrUpdateFinancialManagement({
    super.key,
    this.report,
    required this.creatorId,
    required this.companyId,
  });

  @override
  State<CreateOrUpdateFinancialManagement> createState() =>
      _CreateOrUpdateFinancialManagementState();
}

class _CreateOrUpdateFinancialManagementState
    extends State<CreateOrUpdateFinancialManagement> {
  final TextEditingController _txnTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _txnDateController = TextEditingController();
  final RentService _rentService = RentService();

  final _formKey = GlobalKey<FormState>();

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
  }

  void _handleSave() {
    _saveFinancialReport().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      _txnDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null
            ? 'Create Financial Report'
            : 'Update Financial Report'),
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/accountant_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(
                    alpha: 0.2), // Optional tint for better contrast
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _txnTypeController,
                        decoration: InputDecoration(
                          labelText: 'Transaction Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                        ),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Please enter a transaction type'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                        ),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Please enter a description'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalAmountController,
                        decoration: InputDecoration(
                          labelText: 'Total Amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Please enter the total amount'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _txnDateController,
                        decoration: InputDecoration(
                          labelText: 'Transaction Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          return (value == null || value.isEmpty)
                              ? 'Please select a transaction date'
                              : null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Color.fromARGB(255, 66, 143, 107),
                        ),
                        child: Text(
                          widget.report == null ? 'Create' : 'Update',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
