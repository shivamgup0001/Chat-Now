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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVDq4OhFZbn04e9Krgl7vz6hGWngpt4RM',
    appId: '1:735968489032:android:e2f0a98271f1e2c8be727d',
    messagingSenderId: '735968489032',
    projectId: 'chat-now-86705',
    storageBucket: 'chat-now-86705.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0ducFmwb2ARKmuUgiCIq91PqWe4KAcBk',
    appId: '1:735968489032:ios:851e79668ac00920be727d',
    messagingSenderId: '735968489032',
    projectId: 'chat-now-86705',
    storageBucket: 'chat-now-86705.appspot.com',
    androidClientId: '735968489032-qjbsj536hkdivg2s28e74fgafnjj33bf.apps.googleusercontent.com',
    iosClientId: '735968489032-aha2q5bs1pa86osdd34f4aividldngn0.apps.googleusercontent.com',
    iosBundleId: 'com.example.demoChatapp',
  );
}
