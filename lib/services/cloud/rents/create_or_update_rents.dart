//create_or_update_rents.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

import '../../auth/auth_service.dart';

class CreateOrUpdateRentView extends StatefulWidget {
  final CloudRent? rent;
  final List<CloudProfile> profiles;
  final List<DatabaseProperty> properties;

  const CreateOrUpdateRentView({
    Key? key,
    this.rent,
    required this.profiles,
    required this.properties,
  }) : super(key: key);

  @override
  State<CreateOrUpdateRentView> createState() => _CreateOrUpdateRentViewState();
}

class _CreateOrUpdateRentViewState extends State<CreateOrUpdateRentView> {
  final _formKey = GlobalKey<FormState>();

  late CloudProfile selectedProfile;
  late DatabaseProperty selectedProperty;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController rentAmountController;
  late TextEditingController dueDateController;
  String selectedEndContractState = 'Contract_Ended';

  final RentService _rentService = RentService();

  @override
  void initState() {
    super.initState();
    selectedProfile = widget.rent != null
        ? widget.profiles
            .firstWhere((profile) => profile.id == widget.rent!.profileId)
        : widget.profiles.first;
    selectedProperty = widget.rent != null
        ? widget.properties
            .firstWhere((property) => property.id == widget.rent!.propertyId)
        : widget.properties.first;
    startDateController = TextEditingController(
        text: widget.rent?.contract.split(',').first.split(': ').last);
    endDateController = TextEditingController(
        text: widget.rent?.contract.split(',').last.split(': ').last);
    rentAmountController =
        TextEditingController(text: widget.rent?.rentAmount.toString());
    dueDateController = TextEditingController(text: widget.rent?.dueDate);
    selectedEndContractState = widget.rent?.endContract ?? 'Contract_Ended';
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

  Future<void> _saveRent() async {
    if (_formKey.currentState!.validate()) {
      final rentAmount = double.tryParse(rentAmountController.text) ?? 0.0;

      if (widget.rent == null) {
        final currentUser = AuthService.firebase().currentUser!;
        final userId = currentUser.id;
        await _rentService.createRent(
          creatorId: userId,
          profileId: selectedProfile.id,
          propertyId: selectedProperty.id,
          contract:
              'Start: ${startDateController.text}, End: ${endDateController.text}',
          rentAmount: rentAmount,
          dueDate: dueDateController.text,
          endContract: selectedEndContractState,
          paymentStatus: 'Pending', // Assuming default value
        );
      } else {
        await _rentService.updateRent(
          id: widget.rent!.id,
          rentAmount: rentAmount,
          contract:
              'Start: ${startDateController.text}, End: ${endDateController.text}',
          dueDate: dueDateController.text,
          endContract: selectedEndContractState,
          paymentStatus: 'Pending', // Assuming default value
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rent == null ? 'Create Rent' : 'Update Rent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<CloudProfile>(
                value: selectedProfile,
                onChanged: (value) {
                  setState(() {
                    selectedProfile = value!;
                  });
                },
                items: widget.profiles.map((profile) {
                  return DropdownMenuItem<CloudProfile>(
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rent Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rent amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dueDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Due Date'),
                onTap: () => _selectDate(context, dueDateController),
              ),
              DropdownButtonFormField<String>(
                value: selectedEndContractState,
                onChanged: (value) {
                  setState(() {
                    selectedEndContractState = value!;
                  });
                },
                items: [
                  'Contract_Ended',
                  'Contract_Active',
                  'Contract_Prolonged'
                ].map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                decoration:
                    const InputDecoration(labelText: 'End Contract State'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRent,
                child: Text(widget.rent == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
