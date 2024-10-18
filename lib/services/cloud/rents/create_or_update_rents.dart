//create_or_update_rents.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_property_service.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import '../../auth/auth_service.dart';

class CreateOrUpdateRentView extends StatefulWidget {
  final CloudRent? rent;
  final List<CloudProfile> profiles;
  final List<CloudProperty> properties;

  const CreateOrUpdateRentView({
    super.key,
    this.rent,
    required this.profiles,
    required this.properties,
  });

  @override
  State<CreateOrUpdateRentView> createState() => _CreateOrUpdateRentViewState();
}

class _CreateOrUpdateRentViewState extends State<CreateOrUpdateRentView> {
  final _formKey = GlobalKey<FormState>();

  late CloudProfile selectedProfile;
  late CloudProperty selectedProperty;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController rentAmountController;
  late TextEditingController dueDateController;
  String selectedEndContractState = 'Contract_Ended';

  final RentService _rentService = RentService();
  final PropertyService _propertyService = PropertyService();
  List<Map<String, TextEditingController>> payments = [];
  List<CloudProperty> filteredProperties = [];

  @override
  void initState() {
    super.initState();

    selectedProfile = widget.rent != null
        ? widget.profiles.firstWhere(
            (profile) => profile.id == widget.rent!.profileId,
            orElse: () => widget.profiles.first)
        : widget.profiles.first;

    _filterProperties();

    selectedProperty = widget.rent != null
        ? widget.properties.firstWhere(
            (property) => property.id == widget.rent!.propertyId,
            orElse: () => filteredProperties.isNotEmpty
                ? filteredProperties.first
                : widget.properties.first)
        : filteredProperties.isNotEmpty
            ? filteredProperties.first
            : widget.properties.first;

    startDateController = TextEditingController(
        text: widget.rent?.contract.split(',').last.split(': ').last ?? '');
    endDateController = TextEditingController(
        text: widget.rent?.contract.split(',').last.split(': ').last ?? '');
    rentAmountController =
        TextEditingController(text: widget.rent?.rentAmount.toString() ?? '');
    dueDateController = TextEditingController(text: widget.rent?.dueDate ?? '');
    selectedEndContractState = widget.rent?.endContract ?? 'Contract_Ended';

    _initializePayments();
    _updatePropertyIsRented();
  }

  void _filterProperties() {
    filteredProperties = widget.properties.where((property) {
      if (widget.rent != null && property.id == widget.rent!.propertyId) {
        return true;
      }
      return property.companyId == selectedProfile.companyId &&
          !property.isRented;
    }).toList();
  }

  void _initializePayments() {
    if (widget.rent != null && widget.rent!.paymentStatus.isNotEmpty) {
      final paymentData = widget.rent!.paymentStatus.split('; ');
      for (var data in paymentData) {
        final parts = data.split(', ');
        payments.add({
          'paymentCount': TextEditingController(text: parts[0]),
          'advancePayment': TextEditingController(text: parts[1]),
          'paymentType': TextEditingController(text: parts[2]),
          'paymentDate': TextEditingController(text: parts[3]),
          'depositedOn': TextEditingController(text: parts[4]),
          'paymentAmount': TextEditingController(text: parts[5]),
        });
      }
    } else {
      _addPayment();
    }
  }

  void _addPayment() {
    final count = payments.length + 1;

    String getOrdinalSuffix(int count) {
      if (count % 100 >= 11 && count % 100 <= 13) {
        return 'th';
      }
      switch (count % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    payments.add({
      'paymentCount': TextEditingController(
          text: '$count${getOrdinalSuffix(count)} payment'),
      'advancePayment': TextEditingController(),
      'paymentType': TextEditingController(),
      'paymentDate': TextEditingController(),
      'depositedOn': TextEditingController(),
      'paymentAmount': TextEditingController(),
    });
    setState(() {});
  }

  void _removePayment(int index) {
    payments.removeAt(index);
    setState(() {});
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

  String _generatePaymentStatusString() {
    return payments.map((payment) {
      return '${payment['paymentCount']!.text}, ${payment['advancePayment']!.text}, ${payment['paymentType']!.text}, ${payment['paymentDate']!.text}, ${payment['depositedOn']!.text}, ${payment['paymentAmount']!.text}';
    }).join('; ');
  }

  void _updatePropertyIsRented() {
    if (selectedEndContractState == 'Contract_Active' ||
        selectedEndContractState == 'Contract_Prolonged') {
      selectedProperty.isRented = true;
    } else if (selectedEndContractState == 'Contract_Ended') {
      selectedProperty.isRented = false;
    }
  }

  Future<void> _saveRent() async {
    if (_formKey.currentState!.validate()) {
      final rentAmount = double.tryParse(rentAmountController.text) ?? 0.0;
      final paymentStatus = _generatePaymentStatusString();

      _updatePropertyIsRented();

      if (widget.rent == null) {
        final currentUser = AuthService.firebase().currentUser!;
        final companyId = selectedProfile.companyId;
        final userId = currentUser.id;
        await _rentService.createRent(
          creatorId: userId,
          companyId: companyId,
          profileId: selectedProfile.id,
          propertyId: selectedProperty.id,
          contract:
              'Start: ${startDateController.text}, End: ${endDateController.text}',
          rentAmount: rentAmount,
          dueDate: dueDateController.text,
          endContract: selectedEndContractState,
          paymentStatus: paymentStatus,
        );
      } else {
        await _rentService.updateRent(
          id: widget.rent!.id,
          rentAmount: rentAmount,
          contract:
              'Start: ${startDateController.text}, End: ${endDateController.text}',
          dueDate: dueDateController.text,
          endContract: selectedEndContractState,
          paymentStatus: paymentStatus,
        );
      }

      await _propertyService.updateProperty(
        id: selectedProperty.id,
        propertyType: selectedProperty.propertyType,
        floorNumber: selectedProperty.floorNumber,
        propertyNumber: selectedProperty.propertyNumber,
        sizeInSquareMeters: selectedProperty.sizeInSquareMeters,
        pricePerMonth: selectedProperty.pricePerMonth,
        description: selectedProperty.description,
        isRented: selectedProperty.isRented,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rent == null ? 'Create Rent' : 'Update Rent'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/bg/background_dashboard.jpg'), // Replace with your image asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
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
                        _filterProperties();
                        selectedProperty = filteredProperties.isNotEmpty
                            ? filteredProperties.first
                            : selectedProperty;
                      });
                    },
                    items: widget.profiles.map((profile) {
                      return DropdownMenuItem<CloudProfile>(
                        value: profile,
                        child: Text(profile.companyName),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'Select Profile'),
                  ),
                  DropdownButtonFormField<CloudProperty>(
                    value: selectedProperty,
                    onChanged: (value) {
                      setState(() {
                        selectedProperty = value!;
                      });
                    },
                    items: filteredProperties.map((property) {
                      return DropdownMenuItem<CloudProperty>(
                        value: property,
                        child: Text(property.propertyNumber),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'Select Property'),
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
                        _updatePropertyIsRented();
                      });
                    },
                    items: [
                      'Contract_Active',
                      'Contract_Prolonged',
                      'Contract_Ended'
                    ].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'End Contract'),
                  ),
                  const SizedBox(height: 20),
                  ...payments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final payment = entry.value;
                    return Column(
                      key: ValueKey(index),
                      children: [
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => _removePayment(index),
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: payment['paymentCount'],
                          decoration:
                              const InputDecoration(labelText: 'Payment Count'),
                        ),
                        TextFormField(
                          controller: payment['advancePayment'],
                          decoration: const InputDecoration(
                              labelText: 'Advance Payment'),
                        ),
                        TextFormField(
                          controller: payment['paymentType'],
                          decoration:
                              const InputDecoration(labelText: 'Payment Type'),
                        ),
                        TextFormField(
                          controller: payment['paymentDate'],
                          readOnly: true,
                          decoration:
                              const InputDecoration(labelText: 'Payment Date'),
                          onTap: () =>
                              _selectDate(context, payment['paymentDate']!),
                        ),
                        TextFormField(
                          controller: payment['depositedOn'],
                          readOnly: true,
                          decoration:
                              const InputDecoration(labelText: 'Next Payment'),
                          onTap: () =>
                              _selectDate(context, payment['depositedOn']!),
                        ),
                        TextFormField(
                          controller: payment['paymentAmount'],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Payment Amount'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addPayment,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveRent,
                    child: Text(
                        widget.rent == null ? 'Create Rent' : 'Update Rent'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
