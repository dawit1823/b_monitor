//loading_dialog.dart
import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog(
    {required BuildContext context, required Text text}) {
  const dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(
          height: 10.0,
        )
      ],
    ),
  );
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialog);

  return () => Navigator.of(context).pop();
}
