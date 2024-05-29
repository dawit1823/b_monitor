//main.dart
import 'package:flutter/material.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:r_and_e_monitor/dashboard/admin/dashboard.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/dashboard/views/email_verify_view.dart';
import 'package:r_and_e_monitor/dashboard/views/sign_up_view.dart';
import 'package:r_and_e_monitor/dashboard/views/log_in_view.dart';
import 'package:r_and_e_monitor/landing_page.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';
import 'package:r_and_e_monitor/services/cloud/property/property_view.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/new_property.dart';
import 'package:r_and_e_monitor/services/property_mangement/new/property_details_page.dart';
import 'package:r_and_e_monitor/services/rent/rent_service_old/profile/create_or_update_profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //await AuthService.firebase().initialize(); // Initialize Firebase first
  //dotenv.load(fileName: ".env");
  runApp(MaterialApp(
    title: 'Admin Signup Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    // home: const HomePage(),
    //home: const LandingPage(), // Set LandingPage as the home
    routes: {
      hompageRoute: (context) => const HomePage(),
      loginRoute: (context) => const LoginPage(),
      signUpRoute: (context) => const AdminSignUpView(),
      adminDashboardRoute: (context) => const AdminDashboard(),
      emailVerifyRoute: (context) => const VerifyEmailView(),
      propertiesRoute: (context) => const PropertyView(),
      newPropertyRoute: (context) => const NewPropertyView(),
      propertyDetailsPageRoute: (context) => const PropertyDetailsPage(),
      landingPageRoute: (context) => const LandingPage(),
      createOrUpdateProfileRoute: (context) => const CreateOrUpdateProfile(),
      //createOrUpdateRentRoute: (context) => const CreateOrUpdateRentView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialze(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const AdminDashboard();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LandingPage();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
