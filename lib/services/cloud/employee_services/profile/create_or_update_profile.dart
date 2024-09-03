import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/employee_services/cloud_rent_service.dart';

class CreateOrUpdateProfile extends StatefulWidget {
  final CloudProfile? profile;
  final String creatorId;
  final String companyId;

  const CreateOrUpdateProfile({
    super.key,
    this.profile,
    required this.creatorId,
    required this.companyId,
  });

  @override
  State<CreateOrUpdateProfile> createState() => _CreateOrUpdateProfileState();
}

class _CreateOrUpdateProfileState extends State<CreateOrUpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  late String companyName,
      firstName,
      lastName,
      tin,
      email,
      phoneNumber,
      address,
      contractInfo;
  final RentService _rentService = RentService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    companyName = widget.profile?.companyName ?? '';
    firstName = widget.profile?.firstName ?? '';
    lastName = widget.profile?.lastName ?? '';
    tin = widget.profile?.tin ?? '';
    email = widget.profile?.email ?? '';
    phoneNumber = widget.profile?.phoneNumber ?? '';
    address = widget.profile?.address ?? '';
    contractInfo = widget.profile?.contractInfo ?? '';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      _formKey.currentState!.save();

      try {
        if (widget.profile == null) {
          await _rentService.createProfile(
            creatorId: widget.creatorId,
            companyId: widget.companyId,
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
          await _rentService.updateProfile(
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
          Navigator.pop(
              context); // Safely navigate back only if the widget is still mounted.
        }
      } catch (e) {
        // Handle errors (e.g., show a snackbar or dialog)
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: companyName,
                decoration: const InputDecoration(labelText: 'Company Name'),
                onSaved: (value) => companyName = value!,
              ),
              TextFormField(
                initialValue: firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                onSaved: (value) => firstName = value!,
              ),
              TextFormField(
                initialValue: lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                onSaved: (value) => lastName = value!,
              ),
              TextFormField(
                initialValue: tin,
                decoration: const InputDecoration(labelText: 'TIN'),
                onSaved: (value) => tin = value!,
              ),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                initialValue: phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => phoneNumber = value!,
              ),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (value) => address = value!,
              ),
              TextFormField(
                initialValue: contractInfo,
                decoration: const InputDecoration(labelText: 'Contract Info'),
                onSaved: (value) => contractInfo = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
