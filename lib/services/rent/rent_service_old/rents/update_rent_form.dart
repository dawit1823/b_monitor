//update_rent_form.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

import '../../../cloud/employee_services/cloud_rent_service.dart';

class UpdateRentPage extends StatefulWidget {
  final CloudRent rent;
  final List<CloudProfile> profiles;
  final List<DatabaseProperty> properties;

  const UpdateRentPage({
    Key? key,
    required this.rent,
    required this.profiles,
    required this.properties,
  }) : super(key: key);

  @override
  State<UpdateRentPage> createState() => _UpdateRentPageState();
}

class _UpdateRentPageState extends State<UpdateRentPage> {
  final RentService _rentService = RentService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _contractController;
  late TextEditingController _rentAmountController;
  late TextEditingController _dueDateController;
  late TextEditingController _paymentStatusController;

  @override
  void initState() {
    super.initState();
    _contractController = TextEditingController(text: widget.rent.contract);
    _rentAmountController =
        TextEditingController(text: widget.rent.rentAmount.toString());
    _dueDateController = TextEditingController(text: widget.rent.dueDate);
    _paymentStatusController =
        TextEditingController(text: widget.rent.paymentStatus);
  }

  @override
  void dispose() {
    _contractController.dispose();
    _rentAmountController.dispose();
    _dueDateController.dispose();
    _paymentStatusController.dispose();
    super.dispose();
  }

  Future<void> _updateRent() async {
    if (_formKey.currentState!.validate()) {
      final updatedRent = await _rentService.updateRent(
        id: widget.rent.id,
        contract: widget.rent.contract,
        rentAmount: double.parse(_rentAmountController.text),
        dueDate: _dueDateController.text,
        paymentStatus: _paymentStatusController.text,
        endContract: '',
      );

      Navigator.pop(context, updatedRent);
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _dueDateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Rent'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _contractController,
                decoration: const InputDecoration(labelText: 'Contract'),
                validator: (value) => value!.isEmpty ? 'Enter contract' : null,
              ),
              TextFormField(
                controller: _rentAmountController,
                decoration: const InputDecoration(labelText: 'Rent Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter rent amount' : null,
              ),
              TextFormField(
                controller: _dueDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Due Date'),
                onTap: () => _selectDueDate(context),
                validator: (value) => value!.isEmpty ? 'Enter due date' : null,
              ),
              TextFormField(
                controller: _paymentStatusController,
                decoration: const InputDecoration(labelText: 'Payment Status'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter payment status' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRent,
                child: const Text('Update Rent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
