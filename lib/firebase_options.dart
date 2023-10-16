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
    apiKey: 'AIzaSyBG_f_mBXrc8kNJBvEIvP2DWCXLKJnFZE8',
    appId: '1:994037449002:web:db2a62f46a64848f771e53',
    messagingSenderId: '994037449002',
    projectId: 'note-app-flutter-6d90a',
    authDomain: 'note-app-flutter-6d90a.firebaseapp.com',
    databaseURL: 'https://note-app-flutter-6d90a-default-rtdb.firebaseio.com',
    storageBucket: 'note-app-flutter-6d90a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDejKjhMjWhulR7FbwE__stmykz-d7iSw',
    appId: '1:994037449002:android:6680d93efa9139ce771e53',
    messagingSenderId: '994037449002',
    projectId: 'note-app-flutter-6d90a',
    databaseURL: 'https://note-app-flutter-6d90a-default-rtdb.firebaseio.com',
    storageBucket: 'note-app-flutter-6d90a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1YVMH4vhoYaddoH8-eANXg6AvVlEfS4o',
    appId: '1:994037449002:ios:3f6fad8069281549771e53',
    messagingSenderId: '994037449002',
    projectId: 'note-app-flutter-6d90a',
    databaseURL: 'https://note-app-flutter-6d90a-default-rtdb.firebaseio.com',
    storageBucket: 'note-app-flutter-6d90a.appspot.com',
    androidClientId: '994037449002-bohg0kj4guskh0tnh6qbd0lkmv84cp1f.apps.googleusercontent.com',
    iosClientId: '994037449002-nu57n3dfjb9cagvvgkdfqkg6353et96s.apps.googleusercontent.com',
    iosBundleId: 'com.example.notemobileapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1YVMH4vhoYaddoH8-eANXg6AvVlEfS4o',
    appId: '1:994037449002:ios:cb3cb3a0722063f0771e53',
    messagingSenderId: '994037449002',
    projectId: 'note-app-flutter-6d90a',
    databaseURL: 'https://note-app-flutter-6d90a-default-rtdb.firebaseio.com',
    storageBucket: 'note-app-flutter-6d90a.appspot.com',
    androidClientId: '994037449002-bohg0kj4guskh0tnh6qbd0lkmv84cp1f.apps.googleusercontent.com',
    iosClientId: '994037449002-8bkg6a4chrk61tunkp5id5568cphkpf8.apps.googleusercontent.com',
    iosBundleId: 'com.example.notemobileapp.RunnerTests',
  );
}