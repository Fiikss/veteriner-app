
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] 

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
    apiKey: 'AIzaSyCZUKdibpzCrQI8pvlJiS31iNIsANbzQqE',
    appId: '1:500953147009:web:3aa7c6381159e3e67e4f80',
    messagingSenderId: '500953147009',
    projectId: 'veteriner-app-6b576',
    authDomain: 'veteriner-app-6b576.firebaseapp.com',
    storageBucket: 'veteriner-app-6b576.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfEuGZNBK3-ypcO-ph99NZCT8BON7_KzE',
    appId: '1:500953147009:android:82851cb0c11a17c57e4f80',
    messagingSenderId: '500953147009',
    projectId: 'veteriner-app-6b576',
    storageBucket: 'veteriner-app-6b576.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKYA9mEB7KxQ-gGH7rGYaWDRDgOT7Osl0',
    appId: '1:500953147009:ios:d92a9382d3aa0f5e7e4f80',
    messagingSenderId: '500953147009',
    projectId: 'veteriner-app-6b576',
    storageBucket: 'veteriner-app-6b576.firebasestorage.app',
    iosBundleId: 'com.example.veterinerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAKYA9mEB7KxQ-gGH7rGYaWDRDgOT7Osl0',
    appId: '1:500953147009:ios:d92a9382d3aa0f5e7e4f80',
    messagingSenderId: '500953147009',
    projectId: 'veteriner-app-6b576',
    storageBucket: 'veteriner-app-6b576.firebasestorage.app',
    iosBundleId: 'com.example.veterinerApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCZUKdibpzCrQI8pvlJiS31iNIsANbzQqE',
    appId: '1:500953147009:web:11ad71ee130b62267e4f80',
    messagingSenderId: '500953147009',
    projectId: 'veteriner-app-6b576',
    authDomain: 'veteriner-app-6b576.firebaseapp.com',
    storageBucket: 'veteriner-app-6b576.firebasestorage.app',
  );
}
