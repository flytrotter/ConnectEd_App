import 'package:app_test/components/event_info.dart';
import 'package:app_test/pages/industry/event_form.dart';
import 'package:app_test/pages/industry/industry_home.dart';
import 'package:app_test/pages/industry/industry_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart'; // To get the current user

class CreateEventsPage extends StatelessWidget {
  Future<List<dynamic>?> getUserEvents() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user signed in");
    }

    // Fetch the current user's document from Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    // Check if the 'events' field exists and return it
    if (userSnapshot.exists && userSnapshot.data() != null) {
      var data = userSnapshot.data() as Map<String, dynamic>;
      return data['events'] ?? [];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Create Events'),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: getUserEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading events"));
          }

          List<dynamic>? events = snapshot.data;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: events == null || events.isEmpty
                      ? Text(
                          "No events yet. Create one below.",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[800]),
                        )
                      : SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return EventInfo(
                                  eventId: events[index]); // Display each event
                            },
                          ),
                        ),
                ),
              ),
              Spacer(),
              // Create New Event Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateEventForm()));
                    // Placeholder for "Create New Event" action
                  },
                  icon: Icon(Icons.add, size: 28),
                  label: Text(
                    "Create a new event",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green color
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
                icon: Icons.schedule,
                text: 'Schedule',
                onPressed: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => industry()));
                },
              ),
              GButton(
                icon: Icons.add,
                text: 'Events',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateEventsPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
