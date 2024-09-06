import 'package:app_test/components/get_current_id.dart';
import 'package:app_test/pages/industry/industry_home.dart';
import 'package:app_test/pages/home.dart';
import 'package:app_test/pages/authentication/login.dart';
import 'package:app_test/pages/teacher/new_teacher_home.dart';
import 'package:app_test/pages/authentication/register.dart';
import 'package:app_test/pages/teacher/request_form.dart';
import 'package:app_test/pages/teacher/saved_users.dart';
import 'package:app_test/pages/teacher/old_teacher_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Uncomment this if you want to handle background messages
  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userId = getCurrentUserId();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), //usually loginPage()
      navigatorKey: navigatorKey,
      routes: {
        '/register': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/teacherPage': (context) => TeacherHomePage(),
        '/industryPage': (context) => IndustryHome(),
        // '/schedulePage': (context) => SchedulePage()
        '/savedPage': (context) => SavedUsers(currentUserUid: userId ?? '')
      },
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
    );
  }
}
