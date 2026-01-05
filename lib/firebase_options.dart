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
    apiKey: 'AIzaSyCV05WQwUDjaG8ihijk4EOXJ16O5Y1z4Bo',
    appId: '1:389553174477:web:66829d9a6d909f20087684',
    messagingSenderId: '389553174477',
    projectId: 'study-mate-uc',
    authDomain: 'study-mate-uc.firebaseapp.com',
    storageBucket: 'study-mate-uc.firebasestorage.app',
    measurementId: 'G-E4ET17QMHM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAo2-MVNuq1C9sfcjNKoJuZtiAMndvEW8k',
    appId: '1:389553174477:android:ff52215af6880f74087684',
    messagingSenderId: '389553174477',
    projectId: 'study-mate-uc',
    storageBucket: 'study-mate-uc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkfrJJF0sr1kUdDr-C_2cafts_3xVZjRY',
    appId: '1:389553174477:ios:25799fc09b838b1e087684',
    messagingSenderId: '389553174477',
    projectId: 'study-mate-uc',
    storageBucket: 'study-mate-uc.firebasestorage.app',
    iosBundleId: 'com.example.studyMateFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBkfrJJF0sr1kUdDr-C_2cafts_3xVZjRY',
    appId: '1:389553174477:ios:25799fc09b838b1e087684',
    messagingSenderId: '389553174477',
    projectId: 'study-mate-uc',
    storageBucket: 'study-mate-uc.firebasestorage.app',
    iosBundleId: 'com.example.studyMateFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCV05WQwUDjaG8ihijk4EOXJ16O5Y1z4Bo',
    appId: '1:389553174477:web:f869b189d8039b8a087684',
    messagingSenderId: '389553174477',
    projectId: 'study-mate-uc',
    authDomain: 'study-mate-uc.firebaseapp.com',
    storageBucket: 'study-mate-uc.firebasestorage.app',
    measurementId: 'G-T0GC2DV7G5',
  );
}
