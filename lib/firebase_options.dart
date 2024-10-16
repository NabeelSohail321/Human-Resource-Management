// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAtCHKzZqqnN4iON-lt1SFxIK9i3dtBsEs',
    appId: '1:660204097674:web:0b2d8b8169bb49f9401d73',
    messagingSenderId: '660204097674',
    projectId: 'human-resource-managemen-c24ac',
    authDomain: 'human-resource-managemen-c24ac.firebaseapp.com',
    storageBucket: 'human-resource-managemen-c24ac.appspot.com',
    measurementId: 'G-4BMZP6HF4Q',
    databaseURL: 'https://human-resource-managemen-c24ac-default-rtdb.firebaseio.com/'
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCg2HJ0-4AV73CQH092hzMWRvfrfn1RH8w',
    appId: '1:660204097674:android:39965da04a2a2ca2401d73',
    messagingSenderId: '660204097674',
    projectId: 'human-resource-managemen-c24ac',
    storageBucket: 'human-resource-managemen-c24ac.appspot.com',
    databaseURL: 'https://human-resource-managemen-c24ac-default-rtdb.firebaseio.com/'
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBEhy1ludYCSil1CdTPJ1wOY2tOP7MwJjM',
    appId: '1:660204097674:ios:abfd935cf3a6e7fe401d73',
    messagingSenderId: '660204097674',
    projectId: 'human-resource-managemen-c24ac',
    storageBucket: 'human-resource-managemen-c24ac.appspot.com',
    iosBundleId: 'com.example.humanCapitalManagement',
    databaseURL: 'https://human-resource-managemen-c24ac-default-rtdb.firebaseio.com/'
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBEhy1ludYCSil1CdTPJ1wOY2tOP7MwJjM',
    appId: '1:660204097674:ios:abfd935cf3a6e7fe401d73',
    messagingSenderId: '660204097674',
    projectId: 'human-resource-managemen-c24ac',
    storageBucket: 'human-resource-managemen-c24ac.appspot.com',
    iosBundleId: 'com.example.humanCapitalManagement',
    databaseURL: 'https://human-resource-managemen-c24ac-default-rtdb.firebaseio.com/'
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAtCHKzZqqnN4iON-lt1SFxIK9i3dtBsEs',
    appId: '1:660204097674:web:1e179f5d7209e92a401d73',
    messagingSenderId: '660204097674',
    projectId: 'human-resource-managemen-c24ac',
    authDomain: 'human-resource-managemen-c24ac.firebaseapp.com',
    storageBucket: 'human-resource-managemen-c24ac.appspot.com',
    measurementId: 'G-GSNMDVQR47',
    databaseURL: 'https://human-resource-managemen-c24ac-default-rtdb.firebaseio.com/'
  );
}
