import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
  
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    //  case TargetPlatform.linux:
    //     throw UnsupportedError(
    //       'DefaultFirebaseOptions have not been configured for linux - '
    //       'you can reconfigure this by running the FlutterFire CLI again.',
    //     );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // static const FirebaseOptions web = FirebaseOptions(
  //   apiKey: 'AIzaSyCBsJJ2rO9A18-8jX1SsIP-gk1vqto9RqI',
  //   appId: '1:1026566530718:web:1e3b447509401f12367d8f',
  //   messagingSenderId: '746844572775',
  //   projectId: 'pushnotification-f5b52',
  //   authDomain: 'pushnotification-f5b52.firebaseapp.com',
  //   storageBucket: 'pushnotification-f5b52.appspot.com',
  // );

  static const FirebaseOptions android = FirebaseOptions(
   // apiKey: 'AIzaSyCXSgh8l1kS5ShDj75xB574FvamPjNmgCg',
    appId: '1:343320367868:android:9a7e708a78b458e5c6bd79',
    messagingSenderId: '115907018483',
    projectId: 'jannatkids-a22cd', apiKey: 'AIzaSyCBrvuMgclOjqNyocevgtoHPmrhQcVNRjU',
   // storageBucket: 'pushnotification-f5b52.appspot.com',
  );

  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'AIzaSyCXSgh8l1kS5ShDj75xB574FvamPjNmgCg',
  //   appId: '1:115907018483:android:50d5424b73b0034e240186',
  //   messagingSenderId: '115907018483',
  //   projectId: 'jannatkids-a22cd',
  //  //iosBundleId: 'com.example.jannatkids',
  // );

  // static const FirebaseOptions macos = FirebaseOptions(
  //   apiKey: 'AIzaSyDXxl4vCbMqTgr9h-vD0kivqGpFpIyh24I',
  //   appId: '1:1026566530718:ios:efadca28e1a31062367d8f',
  //   messagingSenderId: '1026566530718',
  //   projectId: 'notifications-5bc9d',
  //   storageBucket: 'notifications-5bc9d.appspot.com',
  //   iosBundleId: 'com.example.apps.RunnerTests',
  // );
}

