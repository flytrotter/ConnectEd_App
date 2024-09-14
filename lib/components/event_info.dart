import 'package:app_test/components/get_current_name.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For random image selection
import 'package:intl/intl.dart';

class EventInfo extends StatelessWidget {
  final String eventId; // Pass the event ID to fetch event data
  final List<String> assetImages = [
    'assets/biology.jpg',
    'assets/cs.jpg',
    'assets/math.jpg',
  ];

  EventInfo({required this.eventId});

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
    // Parse the starting date and time
    DateTime date = startDateTime.toDate();
    String formattedDate = DateFormat('MMMM d, y').format(date);

    // Format date in desired format: September 18, 2024
    // Prepare final sentence
    String result = '$formattedDate from $startTime to $endTime';

    return result;
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

        // Event Data
        var eventData = snapshot.data!;
        String eventName = eventData['event_name'];
        String hostName = eventData['created_by'];
        String description = eventData['description'];
        Timestamp startDateTime = eventData['date'];
        String startTime = eventData['start_time'];
        String endTime = eventData['end_time'];

        String randomImage =
            getRandomImage(); // Select random image from assets

        String formattedDate =
            formatDateRange(startDateTime, startTime, endTime);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  randomImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    Text(
                      eventName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Host Name
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),

                    SizedBox(height: 16),
                    // More Info Button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          // Placeholder for "More Info" action
                        },
                        child: Text("More Info"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
