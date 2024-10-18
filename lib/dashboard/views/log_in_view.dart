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
        centerTitle: true,
        //backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/bg/background_dashboard.jpg', // Ensure the image is in assets folder and listed in pubspec.yaml
            fit: BoxFit.cover,
          ),
          // Content with an overlay to make the form more readable
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          Padding(
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
                    MaterialPageRoute(
                        builder: (context) => const UserChecker()),
                  );
                } else if (state is AuthStateNeedsVerification) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VerifyEmailView()),
                  );
                }
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: _emailController.text.isEmpty
                            ? 'Email cannot be empty'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Input Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: _passwordController.text.isEmpty
                            ? 'Password cannot be empty'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonEnabled
                            ? Colors.deepPurple
                            : Colors.grey, // Disable color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
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
          ),
        ],
      ),
    );
  }
}
