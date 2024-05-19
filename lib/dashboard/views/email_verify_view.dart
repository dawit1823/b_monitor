import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/constants/routes.dart';
import 'package:r_and_e_monitor/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
      ),
      body: Column(children: [
        const Text("We've sent you an email, open the email and verify."),
        const Text("If you haven't get the Email press the button below."),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().currentUser;
          },
          child: const Text("Send Email Verification"),
        ),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().sendEmailVerification();
            Navigator.of(context).pushNamedAndRemoveUntil(
              landingPageRoute,
              (route) => false,
            );
          },
          child: const Text("restart"),
        )
      ]),
    );
  }
}
