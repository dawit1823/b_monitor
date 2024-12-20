import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import '../../auth/auth_service.dart';
import '../employee_services/cloud_rent_service.dart';

class CreateOrUpdateCompany extends StatefulWidget {
  final CloudCompany? company;

  const CreateOrUpdateCompany({super.key, this.company});

  @override
  State<CreateOrUpdateCompany> createState() => _CreateOrUpdateCompanyState();
}

class _CreateOrUpdateCompanyState extends State<CreateOrUpdateCompany> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.companyName;
      _ownerController.text = widget.company!.companyOwner;
      _emailController.text = widget.company!.emailAddress;
      _phoneController.text = widget.company!.phone;
      _addressController.text = widget.company!.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createOrUpdateCompany() async {
    final RentService rentService = RentService();
    if (widget.company == null) {
      await rentService.createCompany(
        creatorId: AuthService.firebase().currentUser!.id,
        companyName: _nameController.text,
        companyOwner: _ownerController.text,
        emailAddress: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
    } else {
      await rentService.updateCompany(
        id: widget.company!.id,
        companyName: _nameController.text,
        companyOwner: _ownerController.text,
        companyAddress: _addressController.text,
        companyEmail: _emailController.text,
        companyPhone: _phoneController.text,
      );
    }
  }

  void _onSubmit() async {
    await _createOrUpdateCompany();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.company != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdating ? 'Update Company' : 'Create Company'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background with blur effect
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
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isUpdating
                              ? 'Update Company Details'
                              : 'Create a New Company',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _nameController,
                          labelText: 'Company Name',
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ownerController,
                          labelText: 'Company Owner',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          labelText: 'Phone',
                          icon: Icons.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          labelText: 'Address',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(isUpdating ? 'Update' : 'Create'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white),
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
    );
  }
}
