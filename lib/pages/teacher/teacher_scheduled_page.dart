import 'package:app_test/components/get_current_id.dart';
import 'package:app_test/components/uid_to_name.dart';
import 'package:app_test/pages/teacher/more_meeting_details.dart';
import 'package:app_test/pages/teacher/new_teacher_home.dart';
import 'package:app_test/pages/teacher/saved_users.dart';
import 'package:app_test/pages/teacher/teacher_profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class UpcomingMeetingsPage extends StatefulWidget {
  @override
  _UpcomingMeetingsPageState createState() => _UpcomingMeetingsPageState();
}

class _UpcomingMeetingsPageState extends State<UpcomingMeetingsPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> pendingMeetings = [];
  List<Map<String, dynamic>> approvedMeetings = [];
  int _selectedIndex = 0; // New variable to track selected index

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    final teacherId = getCurrentUserId();

    if (teacherId != null) {
      final now = DateTime.now();

      // Fetch pending meetings from meeting_requests (all pending meetings, past or future)
      final pendingSnapshot = await FirebaseFirestore.instance
          .collection('meeting_requests')
          .where('senderId', isEqualTo: teacherId)
          .where('status', isEqualTo: 'pending')
          .get();

      final pendingList = pendingSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'documentId': doc.id,
          ...data,
        }; // Add the document ID and other meeting request data
      }).toList();

      // Fetch approved meetings from scheduled_meetings (only future meetings)
      final approvedSnapshot = await FirebaseFirestore.instance
          .collection('scheduled_meetings')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final approvedList = approvedSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = DateTime.parse(data['date']);

            String startTime = data["start_time"];

            List<String> timeParts = startTime.split(':');
            int hour = int.parse(timeParts[0]);
            int minute = int.parse(timeParts[1]);

            DateTime combinedDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
            );

            // Assuming 'date' exists in 'scheduled_meetings'
            return (combinedDateTime.isAfter(now))
                ? {'documentId': doc.id, ...data}
                : null; // Only include meetings with future dates
          })
          .where((meeting) => meeting != null)
          .toList();

      setState(() {
        pendingMeetings = pendingList.cast<Map<String, dynamic>>();
        approvedMeetings = approvedList.cast<Map<String, dynamic>>();
      });
    }
  }

  String _formatSlot(Map<String, dynamic> slot) {
    final date = DateTime.parse(slot['date']);
    final startTime = TimeOfDay(
      hour: int.parse(slot['start_time'].split(':')[0]),
      minute: int.parse(slot['start_time'].split(':')[1]),
    );
    final endTime = TimeOfDay(
      hour: int.parse(slot['end_time'].split(':')[0]),
      minute: int.parse(slot['end_time'].split(':')[1]),
    );

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return '${dateFormat.format(date)} from ${timeFormat.format(DateTime(0, 0, 0, startTime.hour, startTime.minute))} to ${timeFormat.format(DateTime(0, 0, 0, endTime.hour, endTime.minute))}';
  }

  // Animation for the pending meetings spinner
  Widget _buildPendingIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        Colors.orange,
      ),
      strokeWidth: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Upcoming Meetings'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Pending Meetings Section
          Text(
            'Pending Meetings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          if (pendingMeetings.isEmpty)
            Center(child: Text('No pending meetings')),
          ...pendingMeetings
              .map((meeting) =>
                  _buildMeetingCard(meeting, isPending: true, onTap: () {
                    // Handle on-tap for pending meetings if needed
                  }))
              .toList(),

          SizedBox(height: 30),

          // Approved Meetings Section
          Text(
            'Scheduled Meetings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          if (approvedMeetings.isEmpty)
            Center(child: Text('No upcoming scheduled meetings')),
          ...approvedMeetings
              .map((meeting) => _buildMeetingCard(meeting, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetingDetailsPage(
                          meetingId: meeting['documentId'],
                        ),
                      ),
                    );
                  }))
              .toList(),
        ],
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
                            builder: (context) => TeacherHomePage()));
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

  Widget _buildMeetingCard(Map<String, dynamic> meeting,
      {bool isPending = false, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          title: isPending
              ? FutureBuilder<String>(
                  future: getFullName(meeting['senderId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    } else if (snapshot.hasError) {
                      return Text('Error loading name');
                    } else {
                      return Text(
                        'Meeting with ${snapshot.data ?? 'Unknown name'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      );
                    }
                  },
                )
              : Text(
                  'Meeting with ${meeting['industryName']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
          subtitle: isPending
              ? Text('Pending Meeting Request')
              : Text(
                  _formatSlot(meeting),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold, // Bold the date
                  ),
                ),
          trailing: isPending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: _buildPendingIndicator(),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
