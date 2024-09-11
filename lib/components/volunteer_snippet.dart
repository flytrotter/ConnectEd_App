import 'package:app_test/pages/industry/industry_profile.dart';
import 'package:app_test/pages/industry/volunteer_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerSnippet extends StatefulWidget {
  final String industryUserId;

  VolunteerSnippet({required this.industryUserId});

  @override
  _VolunteerSnippetState createState() => _VolunteerSnippetState();
}

class _VolunteerSnippetState extends State<VolunteerSnippet> {
  double volunteerHours = 0.0;
  String badge = 'none';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVolunteerData();
  }

  Future<void> _fetchVolunteerData() async {
    try {
      // Fetch user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.industryUserId)
          .get();

      // Get volunteer hours
      double totalHours = userDoc.data()?['volunteer_hours']?.toDouble() ?? 0.0;

      // Update state
      setState(() {
        volunteerHours = totalHours;
        badge = _getBadge(volunteerHours);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching volunteer data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getBadge(double hours) {
    if (hours >= 10) return '🏅';
    if (hours >= 5) return '🥇';
    if (hours >= 1) return '🥈';
    if (hours >= 0.5) return '🥉';
    return ''; // No badge earned
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            padding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 16), // Reduce vertical space
            width: double.infinity, // Make it span the full width of the phone
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space out the elements

              children: [
                Text(
                  'Hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Circular progress bar showing hours out of 10
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (volunteerHours / 10).clamp(0.0, 1.0),
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    // Display the hours in the center of the circle
                    Text(
                      volunteerHours.toStringAsFixed(1),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Badges: $badge', // Display badge as emoji
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                // Button to navigate to full volunteer page
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VolunteerPage(),
                      ),
                    );
                  },
                  child: Text(
                    'More Details',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
  }
}
