import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5szm9f7pULYe6xY11wS5PbUFeHTaEG5U',
    appId: '1:635207628430:ios:87809b4897aa48da08bbdf',
    messagingSenderId: '635207628430',
    projectId: 'plando-83567',
    storageBucket: 'plando-83567.firebasestorage.app',
    iosClientId:
        '289697190381-n8qujlj3b9sv4vdqfnmrrl4bvg0hstja.apps.googleusercontent.com',
    iosBundleId: 'me.plando.plandoapp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5szm9f7pULYe6xY11wS5PbUFeHTaEG5U',
    appId: '1:635207628430:android:87809b4897aa48da08bbdf',
    messagingSenderId: '635207628430',
    projectId: 'plando-83567',
    storageBucket: 'plando-83567.firebasestorage.app',
  );
}
