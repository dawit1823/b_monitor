import 'package:flutter/material.dart';
import '../employee_services/cloud_rent_service.dart';

class CreateOrUpdateReportView extends StatefulWidget {
  final String rentId;
  final String companyId;

  const CreateOrUpdateReportView(
      {super.key, required this.rentId, required this.companyId});

  @override
  State<CreateOrUpdateReportView> createState() =>
      _CreateOrUpdateReportViewState();
}

class _CreateOrUpdateReportViewState extends State<CreateOrUpdateReportView> {
  final RentService _rentService = RentService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _carbonCopyController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _carbonCopyController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _carbonCopyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _rentService.createReport(
          rentId: widget.rentId,
          companyId: widget.companyId,
          reportTitle: _titleController.text,
          reportContent: _contentController.text,
          carbonCopy: _carbonCopyController.text,
          reportDate: _dateController.text,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save report: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create or Update Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Content cannot be empty' : null,
              ),
              TextFormField(
                controller: _carbonCopyController,
                decoration: const InputDecoration(labelText: 'Carbon Copy'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                validator: (value) =>
                    value!.isEmpty ? 'Date cannot be empty' : null,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _saveReport,
                child: const Text('Save Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
