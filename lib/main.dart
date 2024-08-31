import 'package:app_test/components/get_current_id.dart';
import 'package:app_test/pages/industry/industry_home.dart';
import 'package:app_test/pages/home.dart';
import 'package:app_test/pages/authentication/login.dart';
import 'package:app_test/pages/teacher/new_teacher_home.dart';
import 'package:app_test/pages/authentication/register.dart';
import 'package:app_test/pages/teacher/request_form.dart';
import 'package:app_test/pages/teacher/saved_users.dart';
import 'package:app_test/pages/teacher/old_teacher_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    String? userId = getCurrentUserId();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), //usually loginPage()
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
