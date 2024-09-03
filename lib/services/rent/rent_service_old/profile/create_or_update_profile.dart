//create_or_update_profile.dart
import 'package:flutter/material.dart';
import '../../../auth/auth_service.dart';
import '../../../cloud/cloud_data_models.dart';
import '../../../cloud/employee_services/cloud_rent_service.dart';

class CreateOrUpdateProfile extends StatefulWidget {
  final CloudProfile? profile;

  const CreateOrUpdateProfile({super.key, this.profile});

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
  CloudCompany? selectedCompany;
  late Future<List<CloudCompany>> _companiesFuture;

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

    _companiesFuture = _fetchCompanies();

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

  Future<List<CloudCompany>> _fetchCompanies() async {
    final creatorId = AuthService.firebase().currentUser!.id;
    return await RentService().getCompaniesByCreatorId(creatorId: creatorId);
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

  Future<void> _saveProfile() async {
    final creatorId = AuthService.firebase().currentUser!.id;
    final companyId = selectedCompany?.id;
    final companyName = _companyNameController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final tin = _tinController.text;
    final email = _emailController.text;
    final phoneNumber = _phoneNumberController.text;
    final address = _addressController.text;
    final contractInfo = _contractInfoController.text;

    if (companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a company.')),
      );
      return;
    }

    if (widget.profile == null) {
      await RentService().createProfile(
        creatorId: creatorId,
        companyId: companyId,
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
        //companyId: companyId,
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
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.profile == null ? 'Create Profile' : 'Update Profile'),
      ),
      body: FutureBuilder<List<CloudCompany>>(
        future: _companiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No companies found.'));
          } else {
            final companies = snapshot.data!;

            if (selectedCompany == null && companies.isNotEmpty) {
              selectedCompany = companies.first;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<CloudCompany>(
                    value: selectedCompany,
                    onChanged: (value) {
                      setState(() {
                        selectedCompany = value;
                      });
                    },
                    items: companies.map((company) {
                      return DropdownMenuItem<CloudCompany>(
                        value: company,
                        child: Text(company.companyName),
                      );
                    }).toList(),
                    decoration:
                        const InputDecoration(labelText: 'Select Company'),
                  ),
                  const SizedBox(height: 16.0),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _companyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Company Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _tinController,
                            decoration: const InputDecoration(
                              labelText: 'TIN',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _phoneNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _contractInfoController,
                            decoration: const InputDecoration(
                              labelText: 'Contract Info',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
