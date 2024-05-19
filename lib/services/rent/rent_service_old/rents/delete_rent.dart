import 'package:flutter/material.dart';

class DeleteRentDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteRentDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Rent'),
      content: Text('Are you sure you want to delete this rent?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('Delete'),
        ),
      ],
    );
  }
}
