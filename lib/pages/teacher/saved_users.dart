// import 'package:app_test/components/get_current_id.dart';
// import 'package:app_test/components/uid_to_info.dart';
// import 'package:flutter/material.dart';

// class SavedUsers extends StatelessWidget {
//   String? userId = getCurrentUserId();

//   SavedUsers({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Saved Users'),
//       ),
//       body: FutureBuilder<List<Widget>>(
//         future: getUserCards(userId.toString()),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No saved users found.'));
//           }

//           return ListView(
//             children: snapshot.data!,
//           );
//         },
//       ),
//     );
//   }
// }




// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';

// // class SavedUsersPage extends StatefulWidget {
// //   const SavedUsersPage({super.key});

// //   @override
// //   _SavedUsersPageState createState() => _SavedUsersPageState();
// // }

// // class _SavedUsersPageState extends State<SavedUsersPage> {
// //   Future<List<String>> _getSavedUserIDs() async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user == null) return []; // No user logged in

// //     final userDoc = await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(user.uid)
// //         .get();
// //     final List<dynamic> savedUserIDs = userDoc.data()?['saved_users'] ?? [];
// //     return List<String>.from(savedUserIDs);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Saved User IDs')),
// //       body: FutureBuilder<List<String>>(
// //         future: _getSavedUserIDs(),
// //         builder: (context, snapshot) {
// //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //             return Center(child: Text('No saved user IDs found.'));
// //           }

// //           final userIDs = snapshot.data!;

// //           return ListView.builder(
// //             itemCount: userIDs.length,
// //             itemBuilder: (context, index) {
// //               final userID = userIDs[index];
// //               return ListTile(
// //                 title: Text(userID),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
