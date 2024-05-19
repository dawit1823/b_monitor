// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBdS3RRFxktU-EZvi_A9Pe6QxyJD9fPpPM',
    appId: '1:744438887245:web:8fd8312b5102ff78713d04',
    messagingSenderId: '744438887245',
    projectId: 'b-monitor-87558',
    authDomain: 'b-monitor-87558.firebaseapp.com',
    storageBucket: 'b-monitor-87558.appspot.com',
    measurementId: 'G-JB0QHGFC7W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBb5s951d6DOMOGUbJgW88_SWDGLMRtxp0',
    appId: '1:744438887245:android:c666de70000efca2713d04',
    messagingSenderId: '744438887245',
    projectId: 'b-monitor-87558',
    storageBucket: 'b-monitor-87558.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDq-fZargiaGk0bWB3ESgdPyrBGo6BrWqs',
    appId: '1:744438887245:ios:bfffb6ad36d354c3713d04',
    messagingSenderId: '744438887245',
    projectId: 'b-monitor-87558',
    storageBucket: 'b-monitor-87558.appspot.com',
    iosBundleId: 'com.benaber.rAndEMonitor',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDq-fZargiaGk0bWB3ESgdPyrBGo6BrWqs',
    appId: '1:744438887245:ios:d4e0b8f09a28f897713d04',
    messagingSenderId: '744438887245',
    projectId: 'b-monitor-87558',
    storageBucket: 'b-monitor-87558.appspot.com',
    iosBundleId: 'com.benaber.rAndEMonitor.RunnerTests',
  );
}
