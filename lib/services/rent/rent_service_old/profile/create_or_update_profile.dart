import 'dart:ui';

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
        const SnackBar(
            content: Text(
          'Please select a company.',
          selectionColor: Colors.black,
        )),
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
        title: Text(widget.profile == null
            ? 'Create Tenant Profile'
            : 'Update Tenant Profile'),
        elevation: 6.0,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/background_dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(
                    alpha: 0.3), // Optional tint for better contrast
              ),
            ),
          ),
          FutureBuilder<List<CloudCompany>>(
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
                        dropdownColor: Colors.white,
                        iconEnabledColor: Colors.white,
                        iconSize: 24,
                        onChanged: (value) {
                          setState(() {
                            selectedCompany = value;
                          });
                        },
                        items: companies.map((company) {
                          return DropdownMenuItem<CloudCompany>(
                            value: company,
                            child: Text(
                              company.companyName,
                              //selectionColor: Colors.white,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Select Company',
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Card(
                        elevation: 0,
                        color: Colors.black.withValues(alpha: 0.3),
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _companyNameController,
                                label: 'Company Name',
                              ),
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                              ),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                              ),
                              _buildTextField(
                                controller: _tinController,
                                label: 'TIN',
                              ),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                              ),
                              _buildTextField(
                                controller: _phoneNumberController,
                                label: 'Phone Number',
                              ),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Address',
                              ),
                              _buildTextField(
                                controller: _contractInfoController,
                                label: 'Contract Info',
                              ),
                              const SizedBox(height: 24.0),
                              ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 32.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5.0,
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(fontSize: 18),
                                ),
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
