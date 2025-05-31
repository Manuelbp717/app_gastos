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
    apiKey: 'AIzaSyATBiDuNx_NTia4rGrc4hIWrjnhG4iOtdM',
    appId: '1:447586491145:web:7564c1d59c02d43d1251d8',
    messagingSenderId: '447586491145',
    projectId: 'donutapp-e2848',
    authDomain: 'donutapp-e2848.firebaseapp.com',
    storageBucket: 'donutapp-e2848.firebasestorage.app',
    measurementId: 'G-SSC0CC019Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyi76FJwpgUMGl4GLj9XnBwqRkQ6dkS8w',
    appId: '1:447586491145:android:dfffbb93db0a3a691251d8',
    messagingSenderId: '447586491145',
    projectId: 'donutapp-e2848',
    storageBucket: 'donutapp-e2848.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJMm2p7DMOTDDMpODQLBVY8kNe92dlxoo',
    appId: '1:447586491145:ios:0973d46fc00f6ea31251d8',
    messagingSenderId: '447586491145',
    projectId: 'donutapp-e2848',
    storageBucket: 'donutapp-e2848.firebasestorage.app',
    iosBundleId: 'com.example.donutApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJMm2p7DMOTDDMpODQLBVY8kNe92dlxoo',
    appId: '1:447586491145:ios:0973d46fc00f6ea31251d8',
    messagingSenderId: '447586491145',
    projectId: 'donutapp-e2848',
    storageBucket: 'donutapp-e2848.firebasestorage.app',
    iosBundleId: 'com.example.donutApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATBiDuNx_NTia4rGrc4hIWrjnhG4iOtdM',
    appId: '1:447586491145:web:66af454b11eb348a1251d8',
    messagingSenderId: '447586491145',
    projectId: 'donutapp-e2848',
    authDomain: 'donutapp-e2848.firebaseapp.com',
    storageBucket: 'donutapp-e2848.firebasestorage.app',
    measurementId: 'G-FY4JBB13P2',
  );
}
