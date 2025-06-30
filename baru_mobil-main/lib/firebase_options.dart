import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBgb3ctVOIlkqV_KRBHTwt6k1aSx2mATzc',
    appId: '1:38861710573:web:5c1257292d8a2a3e8958e4',
    messagingSenderId: '38861710573',
    projectId: 'baru-mobil-110e6',
    authDomain: 'baru-mobil-110e6.firebaseapp.com',
    storageBucket: 'baru-mobil-110e6.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgb3ctVOIlkqV_KRBHTwt6k1aSx2mATzc',
    appId: '1:38861710573:android:5c1257292d8a2a3e8958e4',
    messagingSenderId: '38861710573',
    projectId: 'baru-mobil-110e6',
    storageBucket: 'baru-mobil-110e6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgb3ctVOIlkqV_KRBHTwt6k1aSx2mATzc',
    appId: '1:38861710573:ios:5c1257292d8a2a3e8958e4',
    messagingSenderId: '38861710573',
    projectId: 'baru-mobil-110e6',
    storageBucket: 'baru-mobil-110e6.appspot.com',
    iosBundleId: 'com.example.baruMobil',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBgb3ctVOIlkqV_KRBHTwt6k1aSx2mATzc',
    appId: '1:38861710573:macos:5c1257292d8a2a3e8958e4',
    messagingSenderId: '38861710573',
    projectId: 'baru-mobil-110e6',
    storageBucket: 'baru-mobil-110e6.appspot.com',
    iosBundleId: 'com.example.baruMobil',
  );

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
}
