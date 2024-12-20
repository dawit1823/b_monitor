import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:url_launcher/url_launcher.dart';

Future<void> checkForUpdate(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(hours: 1),
  ));
  await remoteConfig.fetchAndActivate();
  final latestVersion = remoteConfig.getString('latest_app_version');

  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  if (currentVersion != latestVersion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Available'),
        content: Text('A new version of the app is available.'),
        actions: [
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse('https://github.com/dawit1823/b_monitor.git'));
            },
            child: Text('Update Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
        ],
      ),
    );
  }
}
