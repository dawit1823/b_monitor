// prolong_rent.dart
import 'package:flutter/material.dart';

import '../services/cloud_rent_service.dart';

class ProlongRentFormWidget extends StatefulWidget {
  const ProlongRentFormWidget({
    Key? key,
    required this.rentId,
  }) : super(key: key);

  final String rentId;

  @override
  State<ProlongRentFormWidget> createState() => _ProlongRentFormWidgetState();
}

class _ProlongRentFormWidgetState extends State<ProlongRentFormWidget> {
  late TextEditingController endDateController;
  late TextEditingController newDueDateController;

  final RentService _rentService = RentService();

  @override
  void initState() {
    super.initState();
    endDateController = TextEditingController();
    newDueDateController = TextEditingController();
    _loadRentData();
  }

  Future<void> _loadRentData() async {
    final rent = await _rentService.getRent(id: widget.rentId);
    endDateController.text = rent.dueDate;
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
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
        controller.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prolong Rent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: endDateController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Current End Date (Old Due Date)'),
            ),
            TextFormField(
              controller: newDueDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'New Due Date'),
              onTap: () => _selectDate(context, newDueDateController),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _prolongRent();
              },
              child: const Text('Prolong Rent'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _prolongRent() async {
    try {
      final rent = await _rentService.getRent(id: widget.rentId);
      final newEndDate = endDateController.text;
      final newDueDate = newDueDateController.text;

      await _rentService.updateRent(
        id: widget.rentId,
        contract:
            'Start: ${rent.contract.split(',')[0].split(': ')[1]}, End: $newEndDate',
        rentAmount: rent.rentAmount,
        dueDate: newDueDate,
        paymentStatus: rent.paymentStatus,
        endContract: rent.endContract,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rent prolonged successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error prolonging rent: $e'),
        ),
      );
    }
  }
}
