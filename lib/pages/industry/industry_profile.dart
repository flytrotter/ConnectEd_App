import 'package:app_test/pages/industry/industry_home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class IndustryProfilePage extends StatefulWidget {
  @override
  _IndustryProfilePageState createState() => _IndustryProfilePageState();
}

class _IndustryProfilePageState extends State<IndustryProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? _currentUser;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  TextEditingController _linkedinController = TextEditingController();
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
    'Social Justice ⚖️ ',
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
          _companyNameController.text = userDoc['company_name'];
          _jobTitleController.text = userDoc['job_title'];
          _experienceController.text = userDoc['experience'];
          _linkedinController.text = userDoc['linkedin'];
          _emailController.text = userDoc['email'];
          _interests = List<String>.from(userDoc['interests']);
        });
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'company_name': _companyNameController.text,
        'job_title': _jobTitleController.text,
        'experience': _experienceController.text,
        'linkedin': _linkedinController.text,
        'email': _emailController.text,
        'interests': _interests,
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
        title: Text('Edit Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(labelText: 'Company Name'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(labelText: 'Job Title'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: InputDecoration(labelText: 'Experience'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _linkedinController,
                  decoration: InputDecoration(labelText: 'LinkedIn'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 16),
                // Interests
                Text(
                  'Interests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _interests
                      .map((interest) => Chip(
                            label: Text(interest),
                            onDeleted: () {
                              setState(() {
                                _interests.remove(interest);
                              });
                            },
                          ))
                      .toList(),
                ),
                TextButton(
                  onPressed: () {
                    _selectInterestDialog(context);
                  },
                  child: Text('Add Interest'),
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Save Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      textStyle: TextStyle(fontSize: 18),
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
                            builder: (context) => IndustryHome()));
                  }),
              // GButton(icon: Icons.settings, text: 'Settings'),
              GButton(
                  icon: Icons.person,
                  text: 'Profile',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IndustryProfilePage()));
                  }),
              GButton(
                icon: Icons.event,
                text: 'Schedule',
                onPressed: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => industry()));
                },
              ),
            ],
          ),
        ),
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
          ),
        ],
      ),
    );
  }
}
