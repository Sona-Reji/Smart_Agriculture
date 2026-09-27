import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with FlutterFire plugins.
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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAdJgKb7ZTpAXigbhqjG4a6hZ70wdJ12w',
    appId: '1:15211706857:web:smartagrimonitoring',
    messagingSenderId: '15211706857',
    projectId: 'smart-agriculture-projec-408e8',
    authDomain: 'smart-agriculture-projec-408e8.firebaseapp.com',
    databaseURL: 'https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com',
    storageBucket: 'smart-agriculture-projec-408e8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAdJgKb7ZTpAXigbhqjG4a6hZ70wdJ12w',
    appId: '1:15211706857:android:e1e36a61a4d8d4aa3c7378',
    messagingSenderId: '15211706857',
    projectId: 'smart-agriculture-projec-408e8',
    databaseURL: 'https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com',
    storageBucket: 'smart-agriculture-projec-408e8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAdJgKb7ZTpAXigbhqjG4a6hZ70wdJ12w',
    appId: '1:15211706857:ios:smartagrimonitoring',
    messagingSenderId: '15211706857',
    projectId: 'smart-agriculture-projec-408e8',
    databaseURL: 'https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com',
    storageBucket: 'smart-agriculture-projec-408e8.firebasestorage.app',
    iosBundleId: 'com.example.smartAgriApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAdJgKb7ZTpAXigbhqjG4a6hZ70wdJ12w',
    appId: '1:15211706857:ios:smartagrimonitoring',
    messagingSenderId: '15211706857',
    projectId: 'smart-agriculture-projec-408e8',
    databaseURL: 'https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com',
    storageBucket: 'smart-agriculture-projec-408e8.firebasestorage.app',
    iosBundleId: 'com.example.smartAgriApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAdJgKb7ZTpAXigbhqjG4a6hZ70wdJ12w',
    appId: '1:15211706857:web:smartagrimonitoring',
    messagingSenderId: '15211706857',
    projectId: 'smart-agriculture-projec-408e8',
    authDomain: 'smart-agriculture-projec-408e8.firebaseapp.com',
    databaseURL: 'https://smart-agriculture-projec-408e8-default-rtdb.firebaseio.com',
    storageBucket: 'smart-agriculture-projec-408e8.firebasestorage.app',
  );
}
