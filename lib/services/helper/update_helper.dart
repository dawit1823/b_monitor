import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<void> checkForUpdate(BuildContext context) async {
  const releaseUrl =
      'https://github.com/dawit1823/b_monitor/releases/download/v10/app-release.apk';

  try {
    final response = await http.get(Uri.parse(releaseUrl));
    if (response.statusCode == 200) {
      final releaseData = json.decode(response.body);
      final latestTag = releaseData['tag_name'];
      final downloadUrl = releaseData['assets'][0]['browser_download_url'];

      // Replace this with your app's current version
      const currentVersion = 'v10';

      if (latestTag != currentVersion) {
        showDialog(

          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: const Text(
                'A new version of the app is available. Would you like to update now?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Could not launch download link')),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error checking for updates: $e')),
    );
  }
}
