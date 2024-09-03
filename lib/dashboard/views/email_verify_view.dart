//email_verify_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_bloc.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';

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
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEventSendEmailVerification(),
                );
          },
          child: const Text("Send Email Verification"),
        ),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(
                  const AuthEventLogOut(),
                );
          },
          child: const Text("restart"),
        )
      ]),
    );
  }
}
