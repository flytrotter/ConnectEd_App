import 'package:app_test/components/get_current_id.dart';
import 'package:app_test/components/uid_to_name.dart';
import 'package:app_test/pages/teacher/more_meeting_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class UpcomingMeetingsPage extends StatefulWidget {
  @override
  _UpcomingMeetingsPageState createState() => _UpcomingMeetingsPageState();
}

class _UpcomingMeetingsPageState extends State<UpcomingMeetingsPage> {
  List<Map<String, dynamic>> pendingMeetings = [];
  List<Map<String, dynamic>> approvedMeetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
  }

  Future<void> _fetchMeetings() async {
    final teacherId =
        getCurrentUserId(); // Replace with your method to get the current user's ID

    if (teacherId != null) {
      // Fetch pending meetings from requested_meetings
      final pendingSnapshot = await FirebaseFirestore.instance
          .collection('meeting_requests')
          .where('senderId', isEqualTo: teacherId)
          .where('status', isEqualTo: 'pending')
          .get();

      final pendingList = pendingSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'documentId': doc.id, // Include document ID here
          ...data
        };
      }).toList();

      // Fetch approved meetings from scheduled_meetings
      final approvedSnapshot = await FirebaseFirestore.instance
          .collection('scheduled_meetings')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final approvedList = approvedSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'documentId': doc.id, // Include document ID here
          ...data
        };
      }).toList();

      setState(() {
        pendingMeetings = pendingList;
        approvedMeetings = approvedList;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upcoming Meetings')),
      body: ListView(
        children: [
          // Display pending meetings
          ...pendingMeetings
              .map((meeting) => Card(
                    child: ListTile(
                      title: FutureBuilder<String>(
                        future: getFullName(meeting['senderId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Loading...');
                          } else if (snapshot.hasError) {
                            return Text('Error');
                          } else {
                            return Text(snapshot.data ?? 'No name');
                          }
                        },
                      ),
                      subtitle: Text(_formatSlot(meeting['times'][0])),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(width: 10),
                          Text('Pending',
                              style: TextStyle(backgroundColor: Colors.grey)),
                        ],
                      ),
                    ),
                  ))
              .toList(),

          // Display approved meetings
          ...approvedMeetings
              .map((meeting) => Card(
                    child: ListTile(
                      title: Text(meeting['industryName']),
                      subtitle: Text(_formatSlot(meeting)),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Navigate to meeting details page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeetingDetailsPage(
                                  meetingId: meeting['documentId']),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('View Scheduled Meeting'),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
