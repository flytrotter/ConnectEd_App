import "package:app_test/components/my_button.dart";
import "package:app_test/components/textfield.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    //loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Get the signed-in user
      User? user = userCredential.user;

      if (user != null) {
        // Fetch the user's role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String role = userDoc.get('role');

        // Get the FCM token and store it in Firestore
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? token = await messaging.getToken();
        if (token != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        }

        // Navigate based on the role
        if (role == 'teacher') {
          Navigator.pushReplacementNamed(context, '/teacherPage');
        } else if (role == 'student') {
          Navigator.pushReplacementNamed(context, '/industryPage');
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        return wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        return wrongPasswordMessage();
      }
    }
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Email not found'),
        );
      },
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Password not found'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Image.asset(
                  'assets/Subheading.png', // Make sure you put your logo file in assets and reference it here.
                  width: 400,
                  height: 150,
                ),

                // app name
                const SizedBox(height: 20),
                const Text(
                  "L O G I N",
                  style: TextStyle(fontSize: 20),
                ),

                // email textfield
                const SizedBox(height: 25),
                MyTextfield(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),
                //password
                const SizedBox(height: 10),
                MyTextfield(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController),
                //forgot password
                const SizedBox(height: 10),
                Text("Forgot Password?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),

                //sign in button
                const SizedBox(height: 25),
                MyButton(text: "Login", onTap: login //login,
                    ),
                //register here
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
