import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCyYTTVEb8ofOpeC8zvvtd5wa83kHdC65E',
    appId: '1:416426355539:web:576b9bb4f62a2e97fe4fa6',
    messagingSenderId: '416426355539',
    projectId: 'lifecli-app',
    authDomain: 'lifecli-app.firebaseapp.com',
    storageBucket: 'lifecli-app.firebasestorage.app',
    measurementId: 'G-FDDT1PTT7W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6WWohh-CvMkKY90Q5Nnsm-pLQWow7Ntg',
    appId: '1:416426355539:android:d44a698afbf29e70fe4fa6',
    messagingSenderId: '416426355539',
    projectId: 'lifecli-app',
    storageBucket: 'lifecli-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-3dBXgSfktR3L-BYfOIpGDwixoABnRyg',
    appId: '1:416426355539:ios:e26ec2dcbc661208fe4fa6',
    messagingSenderId: '416426355539',
    projectId: 'lifecli-app',
    storageBucket: 'lifecli-app.firebasestorage.app',
    iosClientId: '416426355539-k4jlcrlgu2ubehigoju75vj6nmhleem3.apps.googleusercontent.com',
    iosBundleId: 'com.lifecli.app',
  );
}
