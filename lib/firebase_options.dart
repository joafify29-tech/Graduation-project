// File generated from Firebase project configuration.
// Do not commit this file to source control.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCRVK-71j2BkAEALsF6uxXD8Z8MjqkJ7E0',
    appId: '1:913019059025:web:38ec5440d3acdecb367170',
    messagingSenderId: '913019059025',
    projectId: 'ai-recovery-app-c6fef',
    authDomain: 'ai-recovery-app-c6fef.firebaseapp.com',
    storageBucket: 'ai-recovery-app-c6fef.firebasestorage.app',
    measurementId: 'G-EEHPV5R8SD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQB5MXzna7TJJ_iTobH4CdapYUTk7LZe0',
    appId: '1:913019059025:android:6a5b9737f63cd3f4367170',
    messagingSenderId: '913019059025',
    projectId: 'ai-recovery-app-c6fef',
    storageBucket: 'ai-recovery-app-c6fef.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCRVK-71j2BkAEALsF6uxXD8Z8MjqkJ7E0',
    appId: '1:913019059025:web:38ec5440d3acdecb367170',
    messagingSenderId: '913019059025',
    projectId: 'ai-recovery-app-c6fef',
    authDomain: 'ai-recovery-app-c6fef.firebaseapp.com',
    storageBucket: 'ai-recovery-app-c6fef.firebasestorage.app',
    measurementId: 'G-EEHPV5R8SD',
  );
}
