import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/dashboard/views/utilities/arguments/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occured',
    content: text,
    optionBuilder: () => {
      'ok': null,
    },
  );
}
