import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Placeholder FirebaseOptions for SuperWeber.
/// These mock values allow the application to compile and run across web and mobile.
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
    apiKey: 'AIzaSyPlaceholderWebApiKeyForSuperWeber',
    appId: '1:1234567890:web:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'superweber-mock-project',
    authDomain: 'superweber-mock-project.firebaseapp.com',
    storageBucket: 'superweber-mock-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderAndroidApiKeyForSuperWeber',
    appId: '1:1234567890:android:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'superweber-mock-project',
    storageBucket: 'superweber-mock-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholderIosApiKeyForSuperWeber',
    appId: '1:1234567890:ios:abcdef123456',
    messagingSenderId: '1234567890',
    projectId: 'superweber-mock-project',
    storageBucket: 'superweber-mock-project.appspot.com',
    iosBundleId: 'com.ufscar.superweber',
  );
}
