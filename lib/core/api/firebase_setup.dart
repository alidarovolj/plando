import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plando/firebase_options.dart';
import 'package:flutter/foundation.dart';

Future<void> initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    if (!kIsWeb) {
      await setupPushNotifications();
    }
  } catch (e, stackTrace) {
    print('Error during Firebase initialization: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> setupPushNotifications() async {
  try {
    final messaging = FirebaseMessaging.instance;

    // Request permission and wait for user response
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Only proceed if permission is granted
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // For iOS, get the APNS token first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await messaging.getAPNSToken();
        print('APNS Token: $apnsToken');

        if (apnsToken == null) {
          print('Failed to get APNS token');
          return;
        }

        // Add a small delay after getting APNS token
        await Future.delayed(const Duration(seconds: 1));
      }

      try {
        // Get the FCM token
        String? fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          print('FCM Token: $fcmToken');
        } else {
          print('Failed to get FCM token');
        }
      } catch (e) {
        print('Error getting FCM token: $e');
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen(
        (String token) {
          print('FCM Token refreshed: $token');
          // Here you can send the token to your server
        },
        onError: (error) {
          print('Error on token refresh: $error');
        },
      );
    }

    // Set up message handlers
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      },
      onError: (error) {
        print('Error on message stream: $error');
      },
    );
  } catch (e, stackTrace) {
    print('Error during push notifications setup: $e');
    print('Stack trace: $stackTrace');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print("Handling a background message: ${message.messageId}");
  } catch (e, stackTrace) {
    print('Error in background message handler: $e');
    print('Stack trace: $stackTrace');
  }
}
