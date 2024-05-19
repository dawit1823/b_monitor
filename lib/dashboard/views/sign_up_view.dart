//sign_up_view.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/dashboard/views/email_verify_view.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/arguments/error_dialog.dart';
import 'package:r_and_e_monitor/services/auth/auth_exceptions.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';

class AdminSignUpView extends StatefulWidget {
  const AdminSignUpView({Key? key}) : super(key: key);

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

  Future<void> _signUp(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      await AuthService.firebase().createUser(
        email: email,
        password: password,
      );
      AuthService.firebase().currentUser;
      await AuthService.firebase().sendEmailVerification();
      Navigator.of(context).pushNamed(emailVerifyRoute);
    } on WeakPasswordAuthException {
      await showErrorDialog(
        context,
        'weak-password',
      );
    } on EmailAlreadyInUseAuthException {
      await showErrorDialog(
        context,
        'email already in use',
      );
    } on InvalidEmailAuthException {
      await showErrorDialog(
        context,
        'invalid Email',
      );
    } on GenericAuthException {
      await showErrorDialog(
        context,
        'Faild To Register!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                errorText:
                    _emailController.text.isEmpty ? 'Email is required' : null,
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
              onPressed: _isButtonEnabled ? () => _signUp(context) : null,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
