import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<List<Widget>> getUserCards(String currentUserUid) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Get the current user's document
    DocumentSnapshot currentUserSnapshot =
        await firestore.collection('users').doc(currentUserUid).get();

    if (!currentUserSnapshot.exists) {
      return [];
    }

    // Get the saved_users array from the current user's document
    List<String> savedUserUids =
        List<String>.from(currentUserSnapshot.get('saved_users') ?? []);

    if (savedUserUids.isEmpty) {
      return [];
    }

    // Fetch profiles for each saved UID
    List<DocumentSnapshot> profiles = await Future.wait(
      savedUserUids.map((uid) => firestore.collection('users').doc(uid).get()),
    );

    // Create user cards for each profile
    List<Widget> userCards = profiles.map((profile) {
      if (!profile.exists) {
        return Container(); // Skip if the profile does not exist
      }

      final data = profile.data() as Map<String, dynamic>;
      final firstName = data['first_name'] ?? 'Unknown';
      final lastName = data['last_name'] ?? 'Unknown';
      final jobTitle = data['job_title'] ?? 'No title';
      final companyName = data['company_name'] ?? 'No company';

      return Card(
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text('$firstName $lastName'),
          subtitle: Text('$jobTitle at $companyName'),
        ),
      );
    }).toList();

    return userCards;
  } catch (e) {
    print('Error fetching user cards: $e');
    return []; // Return an empty list if there is an error
  }
}
