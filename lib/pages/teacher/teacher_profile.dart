import 'package:app_test/pages/teacher/saved_users.dart';
import 'package:app_test/pages/teacher/teacher_scheduled_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TeacherProfile extends StatefulWidget {
  @override
  _TeacherProfileState createState() => _TeacherProfileState();
}

int _selectedIndex = 0; // New variable to track selected index

class _TeacherProfileState extends State<TeacherProfile> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? _currentUser;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _schoolNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  // List of pre-created interests
  List<String> _preCreatedInterests = [
    'Math 🧮',
    'Biology 🧬',
    'History 🏺',
    'English 📚',
    'Computer Science 💻',
    'Chemistry 🧪',
    'Business/Econ 💸',
    'Studio Art 🧑‍🎨',
    'Performing Arts 🎼',
    'Elementary Education 🏫',
    'Engineering ⚙️',
    'Social Justice ⚖️',
    'Human Health 🧑🏽‍⚕️'
  ];

  // Assuming interests are stored as a list of strings
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _firstNameController.text = userDoc['first_name'];
          _lastNameController.text = userDoc['last_name'];
          _schoolNameController.text = userDoc['school_name'];
          _emailController.text = userDoc['email'];
          _interests = List<String>.from(userDoc['subjects']);
        });
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'school_name': _schoolNameController.text,
        'email': _emailController.text,
        'subjects': _interests,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey[200], // Very light gray
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOutlinedTextField(
                    controller: _firstNameController, label: 'First Name'),
                SizedBox(height: 16),
                _buildOutlinedTextField(
                    controller: _lastNameController, label: 'Last Name'),
                SizedBox(height: 16),
                _buildOutlinedTextField(
                    controller: _schoolNameController, label: 'School Name'),
                SizedBox(height: 16),
                _buildOutlinedTextField(
                    controller: _emailController, label: 'Email'),
                SizedBox(height: 24),
                Text(
                  'Interests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _interests
                      .map((interest) => Chip(
                            label: Text(interest),
                            backgroundColor: Colors.grey.shade100,
                            deleteIconColor: Colors.black,
                            onDeleted: () {
                              setState(() {
                                _interests.remove(interest);
                              });
                            },
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _selectInterestDialog(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.grey[500]),
                      SizedBox(width: 4),
                      Text(
                        'Add Interests',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Save Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      textStyle: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(
            horizontal: 20.0, vertical: 10.0), // Margin to make it float
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30.0), // Curved edges
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 10,
              offset: Offset(0, 3), // Shadow effect for floating effect
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black,
            padding: EdgeInsets.all(16),
            gap: 8,
            tabs: [
              GButton(
                  icon: Icons.home,
                  text: 'Home',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeacherProfile()));
                  }),
              // GButton(icon: Icons.settings, text: 'Settings'),
              GButton(
                  icon: Icons.person,
                  text: 'Profile',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeacherProfile()));
                  }),
              GButton(
                icon: Icons.favorite,
                text: 'Saved',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/savedPage');
                },
              ),
              GButton(
                icon: Icons.event,
                text: 'Schedule',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpcomingMeetingsPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedTextField(
      {required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.grey[100], // Light grey, almost white
      ),
    );
  }

  void _selectInterestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Interests'),
        content: SingleChildScrollView(
          child: Column(
            children: _preCreatedInterests.map((interest) {
              return CheckboxListTile(
                title: Text(interest),
                value: _interests.contains(interest),
                activeColor: Colors.grey[600], // Very light accents
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      if (!_interests.contains(interest)) {
                        _interests.add(interest);
                      }
                    } else {
                      _interests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Done'),
            style: TextButton.styleFrom(backgroundColor: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
