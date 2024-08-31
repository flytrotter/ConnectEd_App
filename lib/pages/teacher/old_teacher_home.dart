import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow
        title: const Text('Teacher'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: const Center(child: Text('Welcome, Teacher!')),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(16),
            gap: 8,
            tabs: [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.settings, text: 'Settings'),
              GButton(icon: Icons.favorite, text: 'Favorites'),
              GButton(icon: Icons.search, text: 'Search')
            ],
          ),
        ),
      ),
    );
  }
}
