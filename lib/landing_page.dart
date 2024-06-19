import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/employee/employee_login_page.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, loginRoute),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, signUpRoute),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmployeeLoginPage(),
                ),
              ),
              child: const Text('Accountant Login'),
            ),
            // Add more buttons for other roles
          ],
        ),
      ),
    );
  }
}
