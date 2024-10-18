//delete_dialog.dart
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete?',
    optionBuilder: () => {
      'cancel': false,
      'yes': true,
    },
  ).then((value) => value ?? false);
}
