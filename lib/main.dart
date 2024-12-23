//main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:r_and_e_monitor/dashboard/admin/dashboard.dart';
import 'package:r_and_e_monitor/dashboard/employee/accountant_dashboard.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/dashboard/views/email_verify_view.dart';
import 'package:r_and_e_monitor/dashboard/views/forgot_email_password_view.dart';
import 'package:r_and_e_monitor/dashboard/views/log_in_view.dart';
import 'package:r_and_e_monitor/dashboard/views/sign_up_view.dart';
import 'package:r_and_e_monitor/landing_page.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';
import 'package:r_and_e_monitor/services/auth/bloc/user_bloc.dart';
import 'package:r_and_e_monitor/services/auth/firebase_auth_provider.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/user_checker.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/helper/update_helper.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/create_or_update_properties.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/create_or_update_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    checkForUpdate(context);
    return MaterialApp(
      title: 'Admin Signup Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3D5A80),
          // Add header color
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.lightBlue,
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginPage(),

        signUpRoute: (context) => const AdminSignUpView(),
        forgotPasswordRoute: (context) => const ForgotPasswordView(),
        adminDashboardRoute: (context) => const AdminDashboard(),
        emailVerifyRoute: (context) => const VerifyEmailView(),
        landingPageRoute: (context) => const LandingPage(),
        newPropertyRoute: (context) => const NewPropertyView(),
        createOrUpdateProfileRoute: (context) => const CreateOrUpdateProfile(),
        userCheckerRoute: (context) =>
            const UserChecker(), // Added userCheckerRoute
      },
      onGenerateRoute: (settings) {
        if (settings.name == accountantDashboardRoute) {
          final CloudEmployee employee = settings.arguments as CloudEmployee;
          return MaterialPageRoute(
            builder: (context) => AccountantDashboard(employee: employee),
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait...',
          );
        } else {
          LoadingScreen().hide();
        }

        if (state is AuthStateLoggedIn && state is! AuthStateLoggingIn) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            userCheckerRoute,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const Scaffold(body: UserChecker());
          // Updated
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LandingPage();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const AdminSignUpView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
