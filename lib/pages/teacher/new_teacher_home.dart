import 'package:app_test/components/saved_button.dart';
import 'package:app_test/pages/teacher/more_info.dart';
import 'package:app_test/pages/teacher/saved_users.dart';
import 'package:app_test/pages/teacher/teacher_profile.dart';
import 'package:app_test/pages/teacher/teacher_scheduled_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class TeacherHomePage extends StatefulWidget {
  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  String searchQuery = "";
  String? teacherName;

  // List to store selected categories
  List<String> selectedCategories = [];

  static const List<String> interests = [
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

  @override
  void initState() {
    super.initState();
    _fetchTeacherName();
  }

  Future<void> _fetchTeacherName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        teacherName = "${userDoc['first_name']} ${userDoc['last_name']}";
      });
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Welcome, ${teacherName ?? "Teacher"}',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for professionals...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // Horizontal scrollable categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: interests.map((interest) {
                final isSelected = selectedCategories.contains(interest);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      _toggleCategory(interest);
                    },
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final filteredByCategory = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final interestsList = (data['interests'] as List<dynamic>)
                      .map((e) => e.toString().toLowerCase())
                      .toList();

                  return selectedCategories.isEmpty ||
                      selectedCategories.any((category) =>
                          interestsList.contains(category.toLowerCase()));
                }).toList();

                final professionals = filteredByCategory.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = "${data['first_name']} ${data['last_name']}"
                      .toLowerCase();
                  final jobTitle = data['job_title'].toLowerCase();
                  final companyName = data['company_name'].toLowerCase();
                  final interestsList = (data['interests'] as List<dynamic>)
                      .map((e) => e.toString().toLowerCase())
                      .toList();

                  return fullName.contains(searchQuery) ||
                      jobTitle.contains(searchQuery) ||
                      companyName.contains(searchQuery) ||
                      interestsList
                          .any((interest) => interest.contains(searchQuery));
                }).toList();

                return ListView.builder(
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    final professional = professionals[index];
                    final Map<String, dynamic> data =
                        professional.data() as Map<String, dynamic>;
                    final interestsToShow =
                        (data['interests'] as List<dynamic>).take(2).toList();

                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Icon(Icons.person),
                              radius: 25.0,
                            ),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['first_name']} ${data['last_name']}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    "${data['job_title']} at ${data['company_name']}",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 8.0),
                                  Wrap(
                                    spacing: 6.0,
                                    children: interestsToShow
                                        .map((interest) => Chip(
                                              label: Text(interest),
                                              backgroundColor: Colors.grey[200],
                                            ))
                                        .toList(),
                                  ),
                                  SizedBox(height: 8.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserInfoPage(
                                              userData: data,
                                              userId: professional.id),
                                        ),
                                      );
                                    },
                                    child: Text('Request Meeting'),
                                  ),
                                ],
                              ),
                            ),
                            SaveButton(
                              userId: professional.id,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
}
