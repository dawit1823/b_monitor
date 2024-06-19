import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';

class CreateOrUpdateFinancialManagement extends StatefulWidget {
  final CloudFinancialManagement? financialReport;

  const CreateOrUpdateFinancialManagement({Key? key, this.financialReport})
      : super(key: key);

  @override
  State<CreateOrUpdateFinancialManagement> createState() =>
      _CreateOrUpdateFinancialManagementState();
}

class _CreateOrUpdateFinancialManagementState
    extends State<CreateOrUpdateFinancialManagement> {
  final _formKey = GlobalKey<FormState>();
  final _txnTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _txnDateController = TextEditingController();
  CloudCompany? selectedCompany;
  List<CloudCompany> _companies = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final String _currentUserId;
  final RentService _rentService = RentService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserAndCompanies();
    if (widget.financialReport != null) {
      _txnTypeController.text = widget.financialReport!.txnType;
      _descriptionController.text = widget.financialReport!.discription;
      _totalAmountController.text = widget.financialReport!.totalAmount;
      _txnDateController.text = widget.financialReport!.txnDate;
    }
  }

  Future<void> _fetchCurrentUserAndCompanies() async {
    try {
      final currentUser = AuthService.firebase().currentUser!;
      _currentUserId = currentUser.id;
      final companies =
          await _rentService.getCompaniesByCreatorId(creatorId: _currentUserId);
      setState(() {
        _companies = companies;
        selectedCompany = widget.financialReport != null
            ? companies.firstWhere(
                (company) => company.id == widget.financialReport!.companyId)
            : (companies.isNotEmpty ? companies.first : null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching companies: $e';
        _isLoading = false;
      });
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
    try {
      if (selectedCompany == null) {
        throw Exception('Please select a company.');
      }
      if (_formKey.currentState!.validate()) {
        if (widget.financialReport == null) {
          await _rentService.createFinancialReport(
            creatorId: _currentUserId,
            companyId: selectedCompany!.id,
            txnType: _txnTypeController.text,
            discription: _descriptionController.text,
            totalAmount: _totalAmountController.text,
            txnDate: _txnDateController.text,
          );
        } else {
          await _rentService.updateFinancialReport(
            id: widget.financialReport!.id,
            txnType: _txnTypeController.text,
            discription: _descriptionController.text,
            totalAmount: _totalAmountController.text,
            txnDate: _txnDateController.text,
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving financial report: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.financialReport == null
            ? 'Create Financial Report'
            : 'Update Financial Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<CloudCompany>(
                value: selectedCompany,
                onChanged: (value) {
                  setState(() {
                    selectedCompany = value!;
                  });
                },
                items: _companies.map((company) {
                  return DropdownMenuItem<CloudCompany>(
                    value: company,
                    child: Text(company.companyName ?? ''),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Select Company'),
              ),
              TextFormField(
                controller: _txnTypeController,
                decoration:
                    const InputDecoration(labelText: 'Transaction Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Transaction Type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalAmountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Total Amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _txnDateController,
                decoration:
                    const InputDecoration(labelText: 'Transaction Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Transaction Date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _saveFinancialReport,
                child:
                    Text(widget.financialReport == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
