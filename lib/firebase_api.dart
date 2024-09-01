import "dart:ffi";

import "package:app_test/main.dart";
import "package:firebase_messaging/firebase_messaging.dart";

class FirebaseApi {
  //instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  //function to initialize notifications
  Future<void> initNotifications() async {
//request permission from user
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      announcement: true,
      carPlay: false,
      provisional: false,
      sound: true,
    );
//fretch token FCM

    final fCMToken = await _firebaseMessaging.getToken();

//print the token to send to server normally

    print('Token: $fCMToken');

    initPushNotifications();
  }

  //function to handle received messages
  void HandleMessage(RemoteMessage? message) {
    if (message == null) return;

    // Extract the custom data from the notification
    final data = message.data;

    // Determine which page to navigate to based on the data
    if (data['screen'] == 'industry_home') {
      navigatorKey.currentState?.pushNamed('/industryPage', arguments: message);
    } else if (data['screen'] == 'teacher_home') {
      navigatorKey.currentState?.pushNamed('/teacherPage', arguments: message);
    } else {
      // Default behavior or a fallback page
      navigatorKey.currentState?.pushNamed('/login', arguments: message);
    }
  }

  Future initPushNotifications() async {
    // Handle the message when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then(HandleMessage);

    // Handle the message when the app is in the background but opened via the notification
    FirebaseMessaging.onMessageOpenedApp.listen(HandleMessage);

    // Handle the message when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received a message while in the foreground: ${message.notification?.title}');
      // Optionally, show an in-app alert or dialog
      HandleMessage(message);
    });
  }
}
