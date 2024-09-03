//employee_route.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_state.dart';

class EmployeeRoute extends StatelessWidget {
  const EmployeeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthStateNeedsVerification) {
            Navigator.pushReplacementNamed(context, emailVerifyRoute);
          } else if (state is AuthStateLoggedOut) {
            Navigator.pushReplacementNamed(context, landingPageRoute);
          } else if (state is AuthStateLoggedIn) {
            final user = state.user;
            if (!user.isEmailVerified) {
              Navigator.pushReplacementNamed(context, emailVerifyRoute);
            } else {
              context.read<UserBloc>().add(UserEventCheck(user.email));
            }
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserStateChecking) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserStateFound) {
              return _navigateToDashboard(context, state.employee);
            } else if (state is UserStateNotFound) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, adminDashboardRoute);
              });
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserStateFailure) {
              return Center(
                child: Text('Error: ${state.exception}'),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _navigateToDashboard(BuildContext context, CloudEmployee employee) {
    final routeName = '${employee.role}DashboardRoute';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, routeName, arguments: employee);
    });
    return const Center(child: CircularProgressIndicator());
  }
}
