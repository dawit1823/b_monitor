import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import '../../auth/auth_service.dart';
import '../services/cloud_rent_service.dart';

class CreateOrUpdateCompany extends StatefulWidget {
  final CloudCompany? company;

  const CreateOrUpdateCompany({Key? key, this.company}) : super(key: key);

  @override
  _CreateOrUpdateCompanyState createState() => _CreateOrUpdateCompanyState();
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
        companyAddress: _addressController.text,
        companyEmail: _emailController.text,
        companyPhone: _phoneController.text,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.company == null ? 'Create Company' : 'Update Company'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            TextField(
              controller: _ownerController,
              decoration: InputDecoration(labelText: 'Company Owner'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createOrUpdateCompany,
              child: Text(widget.company == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
