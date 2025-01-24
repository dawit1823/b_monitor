import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart'; // For opening files

class UpdateHelper {
  static const String githubApiUrl =
      "https://api.github.com/repos/dawit1823/b_monitor/releases/latest";
  static const String currentVersion = "v16";

  bool _isDialogOpen = false;

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      _showLoadingDialog(context, "Checking for updates...");
      final response = await http.get(Uri.parse(githubApiUrl));

      if (response.statusCode == 200) {
        final releaseData = jsonDecode(response.body);
        final latestVersion = releaseData["tag_name"];
        final apkUrl = releaseData["assets"][0]["browser_download_url"];
        safePop(context); // Close loading dialog

        if (latestVersion != currentVersion) {
          _showUpdateDialog(context, apkUrl);
        }
      } else {
        safePop(context);
        _showErrorDialog(
            context, "Failed to fetch update info. Please try again.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking for updates: $e");
      }
      safePop(context);
      _showErrorDialog(
          context, "An error occurred while checking for updates.");
    }
  }

  void _showUpdateDialog(BuildContext context, String apkUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Update Available"),
          content: Text(
              "A new version of the app is available. Would you like to update?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                safePop(context);
                _downloadAndInstallApk(context, apkUrl);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Expanded(
                      child: Text(
                    message,
                    style: TextStyle(color: Colors.black),
                  )),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => _isDialogOpen = false);
  }

  void _updateProgressDialog(BuildContext context, String message) {
    if (_isDialogOpen) {
      // Find the dialog and update the message dynamically
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Update the state to reflect the new progress
              setState(() {});
              return AlertDialog(
                content: Row(
                  children: [
                    // const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    Expanded(
                        child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
                  ],
                ),
              );
            },
          );
        },
      ).then((_) => _isDialogOpen = true);
    }
  }

  Future<void> _downloadAndInstallApk(
      BuildContext context, String apkUrl) async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = "${directory!.path}/update.apk";
      final file = File(filePath);

      _showLoadingDialog(context, "Downloading update...");

      final request = http.Request('GET', Uri.parse(apkUrl));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength;
        if (contentLength == null) {
          safePop(context);
          _showErrorDialog(context, "Failed to determine file size.");
          return;
        }

        int downloadedBytes = 0;
        final sink = file.openWrite();
        response.stream.listen(
          (chunk) {
            sink.add(chunk);
            downloadedBytes += chunk.length;

            final percentage =
                (downloadedBytes / contentLength * 100).toStringAsFixed(1);
            _updateProgressDialog(
                context, "Downloading update... $percentage%");
          },
          onDone: () async {
            await sink.close();
            safePop(context);

            if (kDebugMode) {
              print("APK downloaded to $filePath. Attempting installation...");
            }

            _attemptAutomaticInstall(context, filePath);
          },
          onError: (e) {
            safePop(context);
            _showErrorDialog(
                context, "An error occurred during the APK download.");
          },
          cancelOnError: true,
        );
      } else {
        safePop(context);
        _showErrorDialog(
            context, "Failed to download the update. Please try again.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error downloading APK: $e");
      }
      safePop(context);
      _showErrorDialog(context, "An error occurred during the APK download.");
    }
  }

  // Try to initiate an APK installation
  void _attemptAutomaticInstall(BuildContext context, String filePath) async {
    try {
      if (Platform.isAndroid) {
        final result = await OpenFile.open(
            filePath); // Try opening, which should prompt install
        if (result.type == ResultType.error) {
          _showInstallationInstructions(context, filePath);
        }
      }
    } catch (e) {
      _showInstallationInstructions(context, filePath);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            "Error",
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("OK"))
          ],
        );
      },
    );
  }

  void safePop(BuildContext context) {
    if (_isDialogOpen && Navigator.canPop(context)) {
      Navigator.pop(context);
      _isDialogOpen = false;
    }
  }

  // Manual installation instructions
  void _showInstallationInstructions(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            "Download Complete",
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            "The update has been downloaded to $filePath. Open your file manager and install it manually.",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context), child: Text("OK"))
          ],
        );
      },
    );
  }
}
