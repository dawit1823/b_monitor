import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  if (!context.mounted) return false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text(
              'Log Out',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
