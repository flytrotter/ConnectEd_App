import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  final String userId;

  SaveButton({required this.userId});

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      List<dynamic> savedUsers = userDoc['saved_users'] ?? [];
      setState(() {
        isSaved = savedUsers.contains(widget.userId);
      });
    }
  }

  //Test
  Future<void> _toggleSave() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot userDoc = await userRef.get();
      List<dynamic> savedUsers = userDoc['saved_users'] ?? [];

      if (isSaved) {
        savedUsers.remove(widget.userId);
      } else {
        savedUsers.add(widget.userId);
      }

      await userRef.update({'saved_users': savedUsers});

      setState(() {
        isSaved = !isSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
      color: isSaved ? Colors.red : Colors.grey,
      onPressed: _toggleSave,
    );
  }
}
