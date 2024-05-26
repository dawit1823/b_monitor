//create_or_update_profile.dart
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../cloud/cloud_data_models.dart';
import '../../../cloud/services/cloud_rent_service.dart';

class CreateOrUpdateProfile extends StatefulWidget {
  final CloudProfile? profile;

  const CreateOrUpdateProfile({Key? key, this.profile}) : super(key: key);

  @override
  State<CreateOrUpdateProfile> createState() => _CreateOrUpdateProfileState();
}

class _CreateOrUpdateProfileState extends State<CreateOrUpdateProfile> {
  late final TextEditingController _companyNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _tinController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _addressController;
  late final TextEditingController _contractInfoController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _tinController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _contractInfoController = TextEditingController();
    if (widget.profile != null) {
      _companyNameController.text = widget.profile!.companyName;
      _firstNameController.text = widget.profile!.firstName;
      _lastNameController.text = widget.profile!.lastName;
      _tinController.text = widget.profile!.tin;
      _emailController.text = widget.profile!.email;
      _phoneNumberController.text = widget.profile!.phoneNumber;
      _addressController.text = widget.profile!.address;
      _contractInfoController.text = widget.profile!.contractInfo;
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tinController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _contractInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.profile == null ? 'Create Profile' : 'Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(hintText: 'Company Name'),
            ),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(hintText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(hintText: 'Last Name'),
            ),
            TextField(
              controller: _tinController,
              decoration: const InputDecoration(hintText: 'TIN'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(hintText: 'Phone Number'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(hintText: 'Address'),
            ),
            TextField(
              controller: _contractInfoController,
              decoration: const InputDecoration(hintText: 'Contract Info'),
            ),
            ElevatedButton(
              onPressed: () async {
                final creatorId = AuthService.firebase().currentUser!.id;
                final companyName = _companyNameController.text;
                final firstName = _firstNameController.text;
                final lastName = _lastNameController.text;
                final tin = _tinController.text;
                final email = _emailController.text;
                final phoneNumber = _phoneNumberController.text;
                final address = _addressController.text;
                final contractInfo = _contractInfoController.text;

                if (widget.profile == null) {
                  await RentService().createProfile(
                    creatorId: creatorId,
                    companyName: companyName,
                    firstName: firstName,
                    lastName: lastName,
                    tin: tin,
                    email: email,
                    phoneNumber: phoneNumber,
                    address: address,
                    contractInfo: contractInfo,
                  );
                } else {
                  await RentService().updateProfile(
                    id: widget.profile!.id,
                    companyName: companyName,
                    firstName: firstName,
                    lastName: lastName,
                    tin: tin,
                    email: email,
                    phoneNumber: phoneNumber,
                    address: address,
                    contractInfo: contractInfo,
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
