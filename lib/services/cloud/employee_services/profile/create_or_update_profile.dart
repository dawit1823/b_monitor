import 'dart:ui';
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
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
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
        backgroundColor: Color.fromARGB(255, 66, 143, 107),
        title: Text(
          widget.profile == null
              ? 'Create Tenant Profile'
              : 'Update Tenant Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/accountant_dashboard.jpg'),
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
          // Form Content with Blurred Background
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Tenant Profile Information',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Company Name',
                            initialValue: companyName,
                            onSaved: (value) => companyName = value!,
                          ),
                          _buildTextField(
                            label: 'First Name',
                            initialValue: firstName,
                            onSaved: (value) => firstName = value!,
                          ),
                          _buildTextField(
                            label: 'Last Name',
                            initialValue: lastName,
                            onSaved: (value) => lastName = value!,
                          ),
                          _buildTextField(
                            label: 'TIN',
                            initialValue: tin,
                            onSaved: (value) => tin = value!,
                          ),
                          _buildTextField(
                            label: 'Email',
                            initialValue: email,
                            onSaved: (value) => email = value!,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildTextField(
                            label: 'Phone Number',
                            initialValue: phoneNumber,
                            onSaved: (value) => phoneNumber = value!,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildTextField(
                            label: 'Address',
                            initialValue: address,
                            onSaved: (value) => address = value!,
                          ),
                          _buildTextField(
                            label: 'Contract Info',
                            initialValue: contractInfo,
                            onSaved: (value) => contractInfo = value!,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Save Profile',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.50,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFEE6C4D),
              width: 2.0,
            ),
          ),
        ),
        onSaved: onSaved,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
