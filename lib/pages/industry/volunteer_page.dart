import 'dart:io';

import 'package:app_test/components/get_current_id.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

class VolunteerPage extends StatefulWidget {
  final String? industryUserId = getCurrentUserId();

  VolunteerPage({super.key});

  @override
  _VolunteerPageState createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  double volunteerHours = 0.0;
  String badge = 'none';
  List<DocumentSnapshot> pastMeetings = [];
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

      // Fetch past meetings
      final meetingsSnapshot = await FirebaseFirestore.instance
          .collection('scheduled_meetings')
          .where('industryId', isEqualTo: widget.industryUserId)
          .where('date', isLessThan: DateTime.now().toIso8601String())
          .get();

      List<DocumentSnapshot> meetings = meetingsSnapshot.docs;

      double totalHours = 0.0;

      for (var meeting in meetings) {
        try {
          // Parse meeting date
          DateTime meetingDate = DateTime.parse(meeting['date']);

          // Parse start_time and end_time
          List<String> startTimeParts =
              (meeting['start_time'] as String).split(":");
          List<String> endTimeParts =
              (meeting['end_time'] as String).split(":");

          if (startTimeParts.length != 2 || endTimeParts.length != 2) {
            print('Invalid time format for meeting ID: ${meeting.id}');
            continue; // Skip this meeting
          }

          // Create DateTime objects for start and end times
          DateTime startTime = DateTime(
            meetingDate.year,
            meetingDate.month,
            meetingDate.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
          );

          DateTime endTime = DateTime(
            meetingDate.year,
            meetingDate.month,
            meetingDate.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );

          // Ensure endTime is after startTime
          if (endTime.isBefore(startTime)) {
            print(
                'End time is before start time for meeting ID: ${meeting.id}');
            continue; // Skip this meeting
          }

          // Calculate duration in hours
          double duration = endTime.difference(startTime).inMinutes / 60.0;

          totalHours += duration;
        } catch (e) {
          print('Error parsing meeting ID: ${meeting.id} - $e');
          continue; // Skip this meeting on error
        }
      }

      // Update volunteer_hours in Firestore if it has changed
      double existingHours =
          userDoc.data()?['volunteer_hours']?.toDouble() ?? 0.0;

      if (totalHours != existingHours) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.industryUserId)
            .update({'volunteer_hours': totalHours});
      }

      // Update state
      setState(() {
        volunteerHours = totalHours;
        badge = _getBadge(volunteerHours);
        pastMeetings = meetings;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching volunteer data: $e');
      setState(() {
        isLoading = false;
      });
      // Optionally, show a Snackbar or Dialog to inform the user
    }
  }

  String _getBadge(double hours) {
    if (hours >= 10) return 'green';
    if (hours >= 5) return 'gold';
    if (hours >= 1) return 'silver';
    if (hours >= 0.5) return 'bronze';
    return 'none';
  }

  Future<void> _shareOnLinkedIn() async {
    final url =
        "https://www.linkedin.com/shareArticle?mini=true&url=http://yourapp.com&title=I%20have%20volunteered%20$volunteerHours%20hours%20through%20ConnectEd!";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle the error, e.g., show a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch LinkedIn')),
      );
    }
  }

  Future<void> _downloadCertificate() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text(
              'Certificate of Volunteering\n$volunteerHours Hours',
              style: pw.TextStyle(fontSize: 24),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/volunteer_certificate.pdf");
      await file.writeAsBytes(await pdf.save());

      // await Share.shareFiles([file.path], text: 'My Volunteer Certificate');
    } catch (e) {
      print('Error generating certificate: $e');
      // Optionally, show a Snackbar or Dialog to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Dashboard'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    volunteerHours.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Text(
                    'Total Volunteer Hours',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Badge',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          badge.toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: badgeColor(badge),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: _shareOnLinkedIn,
                    icon: Icon(Icons.share, color: Colors.white),
                    label: Text(
                      'Share on LinkedIn',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _downloadCertificate,
                    icon: Icon(Icons.download, color: Colors.white),
                    label: Text(
                      'Download Certificate',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(height: 20),
                  Text(
                    'Previous Meetings:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Expanded(
                    child: pastMeetings.isEmpty
                        ? Center(child: Text('No past meetings found.'))
                        : ListView.builder(
                            itemCount: pastMeetings.length,
                            itemBuilder: (context, index) {
                              final meeting = pastMeetings[index];
                              String teacherName =
                                  meeting['teacherName'] ?? 'Unknown';
                              String date = meeting['date'] ?? 'Unknown Date';
                              String tutorNote =
                                  meeting['tutorNote'] ?? 'No note provided';

                              // Truncate tutorNote to 30 characters if necessary
                              if (tutorNote.length > 30) {
                                tutorNote = tutorNote.substring(0, 30) + '...';
                              }

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  title: Text('Meeting with $teacherName'),
                                  subtitle: Text(
                                    'Date: $date - Note: $tutorNote',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Color badgeColor(String badge) {
    switch (badge) {
      case 'green':
        return Colors.green;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return Colors.brown;
      default:
        return Colors.black;
    }
  }
}
