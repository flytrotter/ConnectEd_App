import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'package:url_launcher/url_launcher.dart';

class MeetingDetailsPage extends StatelessWidget {
  final String meetingId;

  MeetingDetailsPage({required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Details'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('scheduled_meetings')
            .doc(meetingId)
            .get(),
        builder: (context, meetingSnapshot) {
          if (meetingSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!meetingSnapshot.hasData || !meetingSnapshot.data!.exists) {
            return Center(child: Text('No details found.'));
          }

          final meeting = meetingSnapshot.data!.data() as Map<String, dynamic>;
          final industryUserId =
              meeting['industryId'] as String? ?? ''; // Get industry user's ID
          final meetingDate = meeting['date'] as String? ?? 'No date';
          final startTime = meeting['start_time'] as String? ?? 'No start time';
          final endTime = meeting['end_time'] as String? ?? 'No end time';
          final outline = meeting['outline'] as String? ?? 'No outline';
          final meetingLink = meeting['meeting_info'] as String? ?? 'No link';

          if (industryUserId.isEmpty) {
            return Center(child: Text('No industry user details available.'));
          }

          // Fetch the industry user's details from the `users` collection
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(industryUserId)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Center(child: Text('No user details found.'));
              }

              final user = userSnapshot.data!.data() as Map<String, dynamic>;
              final industryName = user['first_name'] + ' ' + user['last_name'];
              final jobTitle = user['job_title'] as String? ?? 'No job title';
              final companyName =
                  user['company_name'] as String? ?? 'No company';
              final contactEmail =
                  user['email'] as String? ?? 'No contact email';
              final linkedinProfile = user['linkedin'] as String?; // Optional

              // Combine date and time into a human-readable format
              final combinedDateTime =
                  _formatDateTime(meetingDate, startTime, endTime);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Icon and Meeting Details Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Centered profile icon
                            Center(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Meeting details
                            Text(
                              industryName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$jobTitle at $companyName',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(
                              combinedDateTime,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Meeting Info (Outline/Meeting link)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Meeting Info',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        outline,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _launchURL(meetingLink);
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Join Meeting: $meetingLink',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Contact and LinkedIn Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _launchEmail(contactEmail);
                          },
                          icon: Icon(Icons.email, color: Colors.white),
                          label: Text('Contact'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (linkedinProfile != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchURL(linkedinProfile);
                            },
                            icon: Icon(Icons.connect_without_contact,
                                color: Colors.white),
                            label: Text('Connect on LinkedIn'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Format the date and time into a human-readable format
  String _formatDateTime(String dateStr, String startTime, String endTime) {
    DateTime date = DateTime.parse(dateStr);

    // Convert start and end time to AM/PM format
    String formattedStartTime =
        DateFormat.jm().format(DateFormat("HH:mm").parse(startTime));
    String formattedEndTime =
        DateFormat.jm().format(DateFormat("HH:mm").parse(endTime));

    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    return '$formattedDate from $formattedStartTime to $formattedEndTime';
  }

  // Launch URL (for meeting link or LinkedIn profile)
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  // Launch Email app
  void _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Meeting Inquiry', // Add a subject if you like
    );
    final url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not send email to $email');
    }
  }
}
