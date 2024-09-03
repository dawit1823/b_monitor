import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import '../../auth/auth_service.dart';
import '../employee_services/cloud_rent_service.dart';

class CreateOrUpdateExpense extends StatefulWidget {
  final CloudExpenses? expense;
  final String? rentId;

  const CreateOrUpdateExpense({super.key, this.expense, this.rentId});

  @override
  State<CreateOrUpdateExpense> createState() => _CreateOrUpdateExpenseState();
}

class _CreateOrUpdateExpenseState extends State<CreateOrUpdateExpense> {
  final RentService _rentService = RentService();
  final _formKey = GlobalKey<FormState>();
  late String _expenceType;
  late String _amount;
  late String _discription;
  late String _date;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _expenceType = widget.expense!.expenceType;
      _amount = widget.expense!.amount;
      _discription = widget.expense!.discription;
      _date = widget.expense!.date;
    } else {
      _expenceType = '';
      _amount = '';
      _discription = '';
      _date = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.expense != null ? 'Update Expense' : 'Create Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _expenceType,
                decoration: const InputDecoration(labelText: 'Expense Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expense type';
                  }
                  return null;
                },
                onSaved: (value) {
                  _expenceType = value!;
                },
              ),
              TextFormField(
                initialValue: _amount,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = value!;
                },
              ),
              TextFormField(
                initialValue: _discription,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _discription = value!;
                },
              ),
              TextFormField(
                initialValue: _date,
                decoration: const InputDecoration(labelText: 'Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onSaved: (value) {
                  _date = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(widget.expense != null ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = AuthService.firebase().currentUser!;
      final creatorId = currentUser.id;

      if (widget.expense != null) {
        // Update expense
        await _rentService.updateExpense(
          id: widget.expense!.id,
          expenceType: _expenceType,
          amount: _amount,
          discription: _discription,
          date: _date,
        );
      } else {
        // Create expense
        final rent = await _rentService.getRent(id: widget.rentId!);
        await _rentService.createExpense(
          creatorId: creatorId,
          propertyId: rent.propertyId,
          rentId: widget.rentId!,
          profileId: rent.profileId,
          expenceType: _expenceType,
          amount: _amount,
          discription: _discription,
          date: _date,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
