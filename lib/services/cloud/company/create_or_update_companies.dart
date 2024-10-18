//create_or_update_companies.dart
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
      // Create new company
      await rentService.createCompany(
        creatorId: AuthService.firebase().currentUser!.id,
        companyName: _nameController.text,
        companyOwner: _ownerController.text,
        emailAddress: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
    } else {
      // Update existing company
      await rentService.updateCompany(
        id: widget.company!.id,
        companyName: _nameController.text,
        companyOwner: _ownerController.text, // Update owner field
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
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.company == null ? 'Create Company' : 'Update Company'),
        backgroundColor: const Color.fromARGB(255, 75, 153, 255),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg/background_dashboard.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  filled: true,
                  fillColor: Colors.white70, // Adjust text field background
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ownerController,
                decoration: const InputDecoration(
                  labelText: 'Company Owner',
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 75, 153, 255),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14.0, horizontal: 28.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(widget.company == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
