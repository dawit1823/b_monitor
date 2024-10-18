//create_or_update_employee.dart
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
                onSaved: (value) => _phoneNumber = value!,
              ),
              TextFormField(
                initialValue: _salary,
                decoration: const InputDecoration(labelText: 'Salary'),
                validator: (value) => value!.isEmpty ? 'Enter salary' : null,
                onSaved: (value) => _salary = value!,
              ),
              TextFormField(
                controller: _contractDateController,
                decoration: const InputDecoration(
                  labelText: 'Date Started',
                  hintText: 'YYYY-MM-DD',
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
              FutureBuilder<QuerySnapshot>(
                future: _rentService.companies.get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final companies = snapshot.data!.docs;
                  return DropdownButtonFormField(
                    value: _companyId.isEmpty ? null : _companyId,
                    decoration: const InputDecoration(labelText: 'Company'),
                    items: companies.map((doc) {
                      final company = doc['companyName'];
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(company),
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
              DropdownButtonFormField(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items:
                    ['accountant', 'secretary', 'manager', 'security', 'other']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
                validator: (value) => value == null ? 'Select a role' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(widget.employee == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
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
