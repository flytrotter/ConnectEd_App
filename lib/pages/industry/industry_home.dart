import 'package:app_test/components/get_current_id.dart';
import 'package:app_test/components/uid_to_name.dart';
import 'package:app_test/pages/industry/approve_deny.dart';
import 'package:app_test/pages/industry/edit_meeting_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class IndustryHome extends StatelessWidget {
  IndustryHome({super.key});
  String? userId = getCurrentUserId();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tutor Home Page'),
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
                                      'Scheduled on: ${DateFormat('MMMM d, yyyy').format((meeting['scheduledAt'] as Timestamp).toDate())} '
                                      'from ${meeting['start_time']} to ${meeting['end_time']}',
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
        ));
  }
}
