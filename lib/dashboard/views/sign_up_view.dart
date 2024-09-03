import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/dashboard/views/email_verify_view.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/services/auth/auth_exceptions.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';

class AdminSignUpView extends StatefulWidget {
  const AdminSignUpView({super.key});

  @override
  State<AdminSignUpView> createState() => _AdminSignUpViewState();
}

class _AdminSignUpViewState extends State<AdminSignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    context.read<AuthBloc>().add(AuthEventRegister(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthStateRegistering) {
              if (state.exception is WeakPasswordAuthException) {
                await showErrorDialog(context, 'Weak password');
              } else if (state.exception is EmailAlreadyInUseAuthException) {
                await showErrorDialog(context, 'Email already in use');
              } else if (state.exception is InvalidEmailAuthException) {
                await showErrorDialog(context, 'Invalid email');
              } else if (state.exception is GenericAuthException) {
                await showErrorDialog(context, 'Failed to register');
              }
            } else if (state is AuthStateNeedsVerification) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const VerifyEmailView()),
              );
            } else if (state is AuthStateLoggedOut) {
              Navigator.pushNamed(context, loginRoute);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: _emailController.text.isEmpty
                      ? 'Email is required'
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  errorText: _passwordController.text.isEmpty
                      ? 'Password is required'
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _signUp : null,
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text("You Are registered first? Login here!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
