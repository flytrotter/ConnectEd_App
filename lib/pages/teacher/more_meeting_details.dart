import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingDetailsPage extends StatelessWidget {
  final String meetingId;

  MeetingDetailsPage({required this.meetingId});

  @override
  Widget build(BuildContext context) {
    // Fetch meeting details based on meetingId
    return Scaffold(
      appBar: AppBar(title: Text('Meeting Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('scheduled_meetings')
            .doc(meetingId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No details found.'));
          }

          final meeting = snapshot.data!.data() as Map<String, dynamic>;
          final industryName = meeting['industryName'] as String? ?? 'Unknown';
          final meetingDate = meeting['date'] as String? ?? 'No date';
          final startTime = meeting['start_time'] as String? ?? 'No start time';
          final endTime = meeting['end_time'] as String? ?? 'No end time';
          final contactEmail =
              meeting['contactEmail'] as String? ?? 'No contact email';
          final outline = meeting['outline'] as String? ?? 'No outline';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Industry User: $industryName',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Date: $meetingDate', style: TextStyle(fontSize: 16)),
                Text('Time: $startTime - $endTime',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Contact Email: $contactEmail',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('Outline:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(outline, style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
