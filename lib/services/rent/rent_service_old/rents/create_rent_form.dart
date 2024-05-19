// create_rent_form.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/rents/rent_service.dart';
import '../../../property_mangement/new/property_service.dart';

class CreateRentFormWidget extends StatefulWidget {
  const CreateRentFormWidget({
    Key? key,
    required this.profiles,
    required this.properties,
  }) : super(key: key);

  final List<DatabaseProfile> profiles;
  final List<DatabaseProperty> properties;

  @override
  State<CreateRentFormWidget> createState() => _CreateRentFormWidgetState();
}

class _CreateRentFormWidgetState extends State<CreateRentFormWidget> {
  late DatabaseProfile selectedProfile;
  late DatabaseProperty selectedProperty;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController rentAmountController;
  late TextEditingController dueDateController;

  final RentService _rentService = RentService();

  @override
  void initState() {
    super.initState();
    selectedProfile = widget.profiles.first;
    selectedProperty = widget.properties.first;
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    rentAmountController = TextEditingController();
    dueDateController = TextEditingController();
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
      appBar: AppBar(title: const Text('Create Rent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<DatabaseProfile>(
              value: selectedProfile,
              onChanged: (value) {
                setState(() {
                  selectedProfile = value!;
                });
              },
              items: widget.profiles.map((profile) {
                return DropdownMenuItem<DatabaseProfile>(
                  value: profile,
                  child: Text(profile.companyName ?? ''),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Profile'),
            ),
            DropdownButtonFormField<DatabaseProperty>(
              value: selectedProperty,
              onChanged: (value) {
                setState(() {
                  selectedProperty = value!;
                });
              },
              items: widget.properties.map((property) {
                return DropdownMenuItem<DatabaseProperty>(
                  value: property,
                  child: Text(property.propertyNumber),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Property'),
            ),
            TextFormField(
              controller: startDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Start Date'),
              onTap: () => _selectDate(context, startDateController),
            ),
            TextFormField(
              controller: endDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'End Date'),
              onTap: () => _selectDate(context, endDateController),
            ),
            TextFormField(
              controller: rentAmountController,
              decoration: const InputDecoration(labelText: 'Rent Amount'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: dueDateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Due Date'),
              onTap: () => _selectDate(context, dueDateController),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _createRent();
              },
              child: const Text('Create Rent'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createRent() async {
    try {
      await _rentService.createRent(
        profileId: selectedProfile.profileId,
        pId: selectedProperty.id,
        contract:
            'Start: ${startDateController.text}, End: ${endDateController.text}',
        rentAmount: double.tryParse(rentAmountController.text) ?? 0.0,
        dueDate: dueDateController.text,
        paymentStatus: 'Pending', // Assuming default value
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rent created successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating property: $e'),
        ),
      );
    }
  }
}
