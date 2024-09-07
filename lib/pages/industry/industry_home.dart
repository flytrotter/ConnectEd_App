import 'package:app_test/components/get_current_id.dart';
import 'package:app_test/components/uid_to_name.dart';
import 'package:app_test/pages/industry/approve_deny.dart';
import 'package:app_test/pages/industry/edit_meeting_details.dart';
import 'package:app_test/pages/industry/industry_profile.dart';
import 'package:app_test/pages/industry/volunteer_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class IndustryHome extends StatefulWidget {
  @override
  _IndustryHomeState createState() => _IndustryHomeState();
}

class _IndustryHomeState extends State<IndustryHome> {
  String? userId = getCurrentUserId();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Tutor Home Page', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.logout, color: Colors.black)),
        ],
        elevation: 1, // Minimalist app bar
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search scheduled meetings...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('meeting_requests')
                  .where('receiverId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final requests = snapshot.data?.docs ?? [];

                // Fetch scheduled meetings from 'scheduled_meetings' collection
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('scheduled_meetings')
                      .where('industryId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, scheduledSnapshot) {
                    if (scheduledSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (scheduledSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${scheduledSnapshot.error}'));
                    }

                    final scheduledMeetings =
                        scheduledSnapshot.data?.docs ?? [];

                    // Filter scheduled meetings based on search query
                    final filteredMeetings = scheduledMeetings.where((meeting) {
                      final teacherId = meeting['teacherId'] as String;
                      return teacherId.contains(searchQuery);
                    }).toList();

                    return ListView(
                      padding: EdgeInsets.all(
                          16.0), // Padding around the main content
                      children: [
                        // Section for Scheduled Meetings
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scheduled Meetings',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              if (filteredMeetings.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'No meetings scheduled yet!',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ...filteredMeetings.map((meeting) {
                                return FutureBuilder<String>(
                                  future: getFullName(meeting['teacherId']),
                                  builder: (context, nameSnapshot) {
                                    if (nameSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text('Loading name...'),
                                      );
                                    }
                                    if (nameSnapshot.hasError) {
                                      return ListTile(
                                        title: Text('Error fetching name'),
                                      );
                                    }
                                    String teacherName =
                                        nameSnapshot.data ?? 'Unknown';

                                    return Card(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      elevation: 3,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.grey[200],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          teacherName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          'Scheduled on: ${_formatDate(meeting['date'], meeting['start_time'], meeting['end_time'])}',
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                        trailing: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            textStyle: TextStyle(fontSize: 12),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditMeetingDetailsPage(
                                                  meetingId:
                                                      meeting.id.toString(),
                                                  requestId:
                                                      meeting['requestId']
                                                          .toString(),
                                                  userId: userId.toString(),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('Edit Details'),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        // Section for Meeting Requests
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 12.0),
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meeting Requests',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              if (requests.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'No requests yet!',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ...requests.map((request) {
                                return FutureBuilder<String>(
                                  future: getFullName(request['senderId']),
                                  builder: (context, nameSnapshot) {
                                    if (nameSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text('Loading name...'),
                                      );
                                    }
                                    if (nameSnapshot.hasError) {
                                      return ListTile(
                                        title: Text('Error fetching name'),
                                      );
                                    }
                                    String senderName =
                                        nameSnapshot.data ?? 'Unknown';
                                    return Card(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      elevation: 3,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        leading: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.grey[200],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          senderName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          request['note'].toString(),
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                        trailing: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ApproveOrDenyPage(
                                                  requestId:
                                                      request.id.toString(),
                                                  userId: userId.toString(),
                                                  teacherId:
                                                      request['senderId'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('Respond'),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // INDUSTRY NAVIGATOR
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
                text: 'Profile Details',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IndustryProfilePage()),
                  );
                },
              ),
              GButton(
                icon: Icons.punch_clock,
                text: 'Volunteer hours',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VolunteerPage(industryUserId: userId)),
                  );
                },
              ),
              GButton(icon: Icons.event, text: 'Schedule'),
            ],
          ),
        ),
      ),
    );
  }
}

// Formatting the date, start time, and end time
String _formatDate(String date, String startTime, String endTime) {
  DateTime parsedDate = DateTime.parse(date);
  List<String> startTimeParts = startTime.split(":");
  List<String> endTimeParts = endTime.split(":");

  DateTime startDateTime = DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    int.parse(startTimeParts[0]),
    int.parse(startTimeParts[1]),
  );
  DateTime endDateTime = DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    int.parse(endTimeParts[0]),
    int.parse(endTimeParts[1]),
  );

  String formattedDate = DateFormat('MMMM d, yyyy').format(parsedDate);
  String formattedStartTime = DateFormat('h:mm a').format(startDateTime);
  String formattedEndTime = DateFormat('h:mm a').format(endDateTime);

  return '$formattedDate from $formattedStartTime to $formattedEndTime';
}
