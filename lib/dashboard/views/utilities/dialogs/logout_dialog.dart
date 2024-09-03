//logout_dialog.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  if (!context.mounted) return false;

  return showGenericDialog<bool>(
    context: context,
    title: 'Log Out',
    content: 'Are you sure?',
    optionBuilder: () => {
      'cancel': false,
      'logout': true,
    },
  ).then((value) => value ?? false);
}
