import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For random image selection

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

        String randomImage =
            getRandomImage(); // Select random image from assets

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
                      "Hosted by: $hostName",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Description (Truncated)
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    // More Info Button
                    Align(
                      alignment: Alignment.centerRight,
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
