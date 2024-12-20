import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../cloud_data_models.dart';
import '../employee_services/cloud_rent_service.dart';

class CreateOrUpdateEmployee extends StatefulWidget {
  final CloudEmployee? employee;

  const CreateOrUpdateEmployee({
    super.key,
    this.employee,
  });

  @override
  State<CreateOrUpdateEmployee> createState() => _CreateOrUpdateEmployeeState();
}

class _CreateOrUpdateEmployeeState extends State<CreateOrUpdateEmployee> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _role;
  late String _email;
  late String _phoneNumber;
  late String _contractInfo;
  late String _companyId;
  late String _salary;
  late String _contractDate;
  final RentService _rentService = RentService();
  final TextEditingController _contractDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _name = widget.employee!.name;
      _role = widget.employee!.role;
      _email = widget.employee!.email;
      _phoneNumber = widget.employee!.phoneNumber;
      _contractInfo = widget.employee!.contractInfo;
      _companyId = widget.employee!.companyId;
      _salary =
          widget.employee!.contractInfo.split(';')[0].split(':')[1].trim();
      _contractDate =
          widget.employee!.contractInfo.split(';')[1].split(':')[1].trim();
      _contractDateController.text = _contractDate;
    } else {
      _name = '';
      _role = 'accountant';
      _email = '';
      _phoneNumber = '';
      _contractInfo = '';
      _companyId = '';
      _salary = '';
      _contractDate = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.employee == null ? 'Create Employee' : 'Update Employee'),
      ),
      body: Stack(
        children: [
          // Background image
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
                    alpha: 0.4), // Optional tint for better contrast
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              color: Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter name' : null,
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter email' : null,
                        onSaved: (value) => _email = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _phoneNumber,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter phone number' : null,
                        onSaved: (value) => _phoneNumber = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _salary,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'Salary',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter salary' : null,
                        onSaved: (value) => _salary = value!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contractDateController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: 'Date Started',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter date started' : null,
                        onSaved: (value) => _contractDate = value!,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _contractDate =
                                  pickedDate.toIso8601String().split('T').first;
                              _contractDateController.text = _contractDate;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<QuerySnapshot>(
                        future: _rentService.companies.get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final companies = snapshot.data!.docs;
                          return DropdownButtonFormField(
                            iconEnabledColor: Colors.white,
                            value: _companyId.isEmpty ? null : _companyId,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              labelText: 'Company',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            items: companies.map((doc) {
                              final company = doc['companyName'];
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(
                                  company,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _companyId = value!;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Select a company' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        iconEnabledColor: Colors.white,
                        value: _role,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          // iconColor: Colors.white,

                          labelText: 'Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        items: [
                          'accountant',
                          // 'secretary',
                          // 'manager',
                          // 'security',
                          // 'other'
                        ].map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _role = value!;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Select a role' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          widget.employee == null ? 'Create' : 'Update',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _contractInfo = 'Salary: $_salary; Contract Date: $_contractDate';

      if (widget.employee == null) {
        _rentService.createEmployee(
          creatorId: AuthService.firebase().currentUser!.id,
          companyId: _companyId,
          role: _role,
          name: _name,
          email: _email,
          phoneNumber: _phoneNumber,
          contractInfo: _contractInfo,
        );
      } else {
        _rentService.updateEmployee(
          id: widget.employee!.id,
          role: _role,
          name: _name,
          email: _email,
          phoneNumber: _phoneNumber,
          contractInfo: _contractInfo,
        );
      }
      Navigator.of(context).pop();
    }
  }
}
