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

class IndustryHome extends StatelessWidget {
  IndustryHome({super.key});
  String? userId = getCurrentUserId();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Tutor Home Page'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: Icon(Icons.logout)),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
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

                final scheduledMeetings = scheduledSnapshot.data?.docs ?? [];

                return ListView(
                  children: [
                    // Section for Scheduled Meetings
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled Meetings',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          if (scheduledMeetings.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('No meetings scheduled yet!'),
                            ),
                          ...scheduledMeetings.map((meeting) {
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
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(teacherName),
                                    subtitle: Text(
                                      'Scheduled on: ${_formatDate(meeting['date'], meeting['start_time'], meeting['end_time'])}', // Refactored to handle correct date and time formatting
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green),
                                        SizedBox(width: 5),
                                        Text('Scheduled'),
                                        ElevatedButton(
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
                                                ));

                                            // TODO: Add functionality for editing meeting details
                                          },
                                          child: Text('Edit Meeting Details'),
                                        ),
                                      ],
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
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting Requests',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          if (requests.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('No requests yet!'),
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
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(senderName),
                                    subtitle: Text(request['note'].toString()),
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
                                                        request['senderId']),
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
        //INDUSTRY NAVIGATOR
        bottomNavigationBar: Container(
            color: Colors.black,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
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
                          ); // Navigator.pushReplacementNamed(context, '/savedPage');
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
                          ); // Navigator.pushReplacementNamed(context, '/savedPage');
                        },
                      ),
                      GButton(
                          icon: Icons.event,
                          text: 'Schedule',
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => UpcomingMeetingsPage(
                            //             // Pass the tutor's name]))
                            //             )));
                          })
                    ]))));
  }
}

String _formatDate(String date, String startTime, String endTime) {
  // Step 1: Parse the date string (assumed to be in the format '2024-09-06T00:00:00.000') into a DateTime object
  DateTime parsedDate = DateTime.parse(date);

  // Step 2: Parse the start time and end time into DateTime objects
  // This assumes that the start_time and end_time are in 24-hour (military) time format like '14:10' and '14:40'
  // For this, we'll split the time strings and combine them with the parsedDate
  List<String> startTimeParts = startTime.split(":");
  List<String> endTimeParts = endTime.split(":");

  // Create DateTime objects for the start and end times
  DateTime startDateTime = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]));
  DateTime endDateTime = DateTime(parsedDate.year, parsedDate.month,
      parsedDate.day, int.parse(endTimeParts[0]), int.parse(endTimeParts[1]));

  // Step 3: Format the date to a more human-readable format, e.g., 'September 6, 2024'
  String formattedDate = DateFormat('MMMM d, yyyy').format(parsedDate);

  // Step 4: Format the start and end times from 24-hour format to 12-hour format, e.g., '2:10 PM'
  String formattedStartTime = DateFormat('h:mm a')
      .format(startDateTime); // 'h:mm a' converts to 12-hour AM/PM format
  String formattedEndTime = DateFormat('h:mm a').format(endDateTime);

  // Step 5: Return the combined formatted date and times as a string
  return '$formattedDate from $formattedStartTime to $formattedEndTime';
}
