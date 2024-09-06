import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getEmail(String uid) async {
  try {
    // Reference to the Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get the document snapshot for the user with the given UID
    DocumentSnapshot userDoc = await users.doc(uid).get();

    if (userDoc.exists) {
      // Extract the first name and last name from the document
      String email = userDoc.get('email') ?? '';

      // Return the full name as a single string
      return email;
    } else {
      // Handle the case where the user document does not exist
      return '';
    }
  } catch (e) {
    // Handle errors
    print('Error fetching user: $e');
    return '';
  }
}
