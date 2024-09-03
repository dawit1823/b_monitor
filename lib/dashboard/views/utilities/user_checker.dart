// user_checker.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_state.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';

class UserChecker extends StatefulWidget {
  const UserChecker({super.key});

  @override
  State<UserChecker> createState() => _UserCheckerState();
}

class _UserCheckerState extends State<UserChecker> {
  StreamSubscription<UserState>? _userStateSubscription;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<UserBloc>().add(UserEventCheck(user.email!));
    }

    _userStateSubscription =
        context.read<UserBloc>().stream.listen((UserState state) {
      if (state is UserStateFound) {
        _navigateToDashboard(state.employee);
      } else if (state is UserStateNotFound) {
        _navigateToAdminDashboard();
      } else if (state is UserStateFailure) {
        Navigator.pushNamed(
          context,
          landingPageRoute,
        );
      }
    });

    _authStateSubscription =
        context.read<AuthBloc>().stream.listen((AuthState state) {
      if ((state.isLoading)) {
        _showLoadingScreen();
      } else {
        _hideLoadingScreen();
      }
    });
  }

  @override
  void dispose() {
    _userStateSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _navigateToDashboard(CloudEmployee employee) {
    switch (employee.role) {
      case 'admin':
        Navigator.pushNamedAndRemoveUntil(
            context, adminDashboardRoute, (route) => false);
        break;
      case 'accountant':
        Navigator.pushNamedAndRemoveUntil(
          context,
          accountantDashboardRoute,
          (route) => false,
          arguments: employee,
        );
        break;
      default:
        _navigateToAdminDashboard();
    }
  }

  void _navigateToAdminDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      adminDashboardRoute,
      (route) => false,
    );
  }

  void _showLoadingScreen() {
    LoadingScreen().show(context: context, text: 'please wait loading...');
  }

  void _hideLoadingScreen() {
    // Implement hiding loading screen
    LoadingScreen().hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserStateFound) {
            _navigateToDashboard(state.employee);
          } else if (state is UserStateNotFound) {
            _navigateToAdminDashboard();
          } else if (state is UserStateFailure) {
            Navigator.pushNamed(context, landingPageRoute);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(); // Adjust as needed for other states
          }
        },
      ),
    );
  }
}
