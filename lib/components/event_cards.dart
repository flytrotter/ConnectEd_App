import 'package:app_test/pages/teacher/event_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For random image selection
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final String eventId; // Event ID to fetch the event data
  final List<String> assetImages = [
    'assets/biology.jpg',
    'assets/cs.jpg',
    'assets/math.jpg',
  ];

  EventCard({required this.eventId});

  Future<Map<String, dynamic>> getEventData() async {
    // Fetch event data from Firestore
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();

    if (eventSnapshot.exists) {
      return eventSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception("Event not found");
    }
  }

  String getRandomImage() {
    final random = Random();
    return assetImages[random.nextInt(assetImages.length)];
  }

  String formatDateRange(
      Timestamp startDateTime, String startTime, String endTime) {
    DateTime date = startDateTime.toDate();
    String formattedDate = DateFormat('MMMM d, y').format(date);
    return '$formattedDate from $startTime to $endTime';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: getEventData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading event"));
          }

          if (!snapshot.hasData) {
            return Center(child: Text("Event not found"));
          }

          var eventData = snapshot.data!;
          String eventName = eventData['event_name'];
          Timestamp startDateTime = eventData['date'];
          String startTime = eventData['start_time'];
          String endTime = eventData['end_time'];

          String randomImage = getRandomImage();
          String formattedDate =
              formatDateRange(startDateTime, startTime, endTime);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Background image with fade to black at the bottom
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(randomImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                        ],
                      ),
                    ),
                  ),
                ),

                // Heart button at the top-right corner
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.favorite_border),
                    color: Colors.white.withOpacity(0.7),
                    onPressed: () {
                      // Handle heart button click
                    },
                  ),
                ),

                // Event details (name, date, button)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Event name and date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Event Name with Ellipsis if too long
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    eventName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Circular Learn More Button with Arrow Icon
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventSignUp(eventId: eventId),
                                        ),
                                      );

                                      // Handle Learn More action
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),

                            // Event Date (truncated if too long)
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
