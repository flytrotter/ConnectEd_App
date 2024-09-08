import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getCurrentUserFullName() async {
  try {
    // Get the current user from Firebase Authentication
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Get the document snapshot for the current user
      DocumentSnapshot userDoc = await users.doc(uid).get();

      if (userDoc.exists) {
        // Extract the first name and last name from the document
        String firstName = userDoc.get('first_name') ?? '';
        String lastName = userDoc.get('last_name') ?? '';

        // Return the full name as a single string
        return '$firstName $lastName';
      } else {
        // Handle the case where the user document does not exist
        return '';
      }
    } else {
      // Handle the case where there is no current user
      return '';
    }
  } catch (e) {
    // Handle errors
    print('Error fetching user: $e');
    return '';
  }
}
