//password_reset_email_sent_dialog.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'We have now sent you a password reset link. Please check your email for more information.',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
