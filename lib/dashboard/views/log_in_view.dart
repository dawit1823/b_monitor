import 'dart:ui';

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
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
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
                    alpha: 0.2), // Optional tint for better contrast
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
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
                      } else if (state.exception
                          is WrongPasswordAuthException) {
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
                  child: Card(
                    elevation: 8.0,
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Input Field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.1),
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Password Input Field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.1),
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Login Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isButtonEnabled
                                  ? Colors.blueGrey
                                  : Colors.white, // Disabled color
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: _isButtonEnabled
                                ? () {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    context.read<AuthBloc>().add(
                                          AuthEventLogIn(email, password),
                                        );
                                  }
                                : null,
                            child: const Text(
                              'Login',
                              selectionColor: Colors.white,
                            ),
                          ),
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
}
