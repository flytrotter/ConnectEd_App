import 'package:firebase_auth/firebase_auth.dart';

String? getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;
  return user
      ?.uid; // Returns the user ID if the user is logged in, otherwise null
}
