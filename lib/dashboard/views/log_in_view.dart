//log_in_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/dashboard/views/email_verify_view.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/error_dialog.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/user_checker.dart';
import 'package:r_and_e_monitor/services/auth/auth_exceptions.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    setState(() {
      _isButtonEnabled = email.isNotEmpty && password.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state.isLoading) {
              LoadingScreen().show(
                  context: context,
                  text: state.loadingText ?? 'Please wait...');
            } else {
              LoadingScreen().hide();
            }

            if (state is AuthStateLoggedOut) {
              if (state.exception is UserNotFoundAuthException) {
                await showErrorDialog(context, "User not found!");
              } else if (state.exception is WrongPasswordAuthException) {
                await showErrorDialog(context, "Wrong credentials");
              } else if (state.exception is GenericAuthException) {
                await showErrorDialog(context, "Authentication error");
              }
            } else if (state is AuthStateLoggedIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserChecker()),
              );
            } else if (state is AuthStateNeedsVerification) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const VerifyEmailView()),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailController.text.isEmpty
                      ? 'Email cannot be empty'
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: _passwordController.text.isEmpty
                      ? 'Password cannot be empty'
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        context.read<AuthBloc>().add(
                              AuthEventLogIn(email, password),
                            );
                      }
                    : null,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
