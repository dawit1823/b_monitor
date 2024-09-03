//add_member.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/dashboard/views/log_in_view.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_state.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedRole;
  final List<String> _roles = [
    'accountant',
    'secretary',
    'manager',
    'Security',
    'others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Temporary Password'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedRole,
              hint: const Text('Select Role'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
              items: _roles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {
                if (state is UserStateRegistered) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'User registered successfully. Verification email sent.'),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else if (state is UserStateFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Error registering user: ${state.exception.toString()}'),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserStateRegistering) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final role = _selectedRole;

                    if (email.isNotEmpty &&
                        password.isNotEmpty &&
                        role != null) {
                      context
                          .read<AuthBloc>()
                          .add(AuthEventRegister(email, password));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                        ),
                      );
                    }
                  },
                  child: const Text('Register'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
