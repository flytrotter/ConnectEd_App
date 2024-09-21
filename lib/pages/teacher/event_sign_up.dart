import 'package:app_test/components/uid_to_name.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EventSignUp extends StatefulWidget {
  final String eventId;

  EventSignUp({required this.eventId});

  @override
  _EventSignUpState createState() => _EventSignUpState();
}

class _EventSignUpState extends State<EventSignUp>
    with SingleTickerProviderStateMixin {
  bool isSignedUp = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  String randomImage = '';

  final List<String> assetImages = [
    'assets/biology.jpg',
    'assets/cs.jpg',
    'assets/math.jpg',
  ];

  String? hostName = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    randomImage = assetImages[Random().nextInt(assetImages.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> signUpForEvent() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      String userName = user.displayName ?? 'Anonymous';

      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.eventId);

      // Add the userId and userName to the 'registeredUsers' array in Firestore
      await eventRef.update({
        'registeredUsers': FieldValue.arrayUnion([
          {'userId': userId, 'userName': userName}
        ]),
      });

      setState(() {
        isSignedUp = true;
      });

      _controller.forward();
      await Future.delayed(Duration(seconds: 1)); // Show checkmark for 1 second
      _controller.reverse();
    }
  }

  String formatDateRange(
      Timestamp startDateTime, String startTime, String endTime) {
    DateTime date = startDateTime.toDate();
    String formattedDate = DateFormat('MMMM d, y').format(date);
    return '$formattedDate from $startTime to $endTime';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text("Error loading event details")));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(body: Center(child: Text("Event not found")));
        }

        var eventData = snapshot.data!.data() as Map<String, dynamic>;
        String eventName = eventData['event_name'];
        Timestamp startDateTime = eventData['date'];
        String startTime = eventData['start_time'];
        String hostName = eventData['created_by'];
        String endTime = eventData['end_time'];
        String longDescription = eventData['description'];
        String formattedDate =
            formatDateRange(startDateTime, startTime, endTime);

        return Scaffold(
          appBar: AppBar(
            title: Text('Event Sign Up'),
          ),
          body: Column(
            children: [
              // Random image at the top
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(randomImage),
                    fit: BoxFit.cover,
                  ),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Host Name
                    FutureBuilder<String>(
                      future: getFullName(hostName), // Fetch the host's name
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading host...');
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Host not found');
                        }

                        return Text(
                          'Hosted by: ${snapshot.data}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                    SizedBox(height: 8),

                    // Date and Time
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),

                    // Long Description
                    Text(
                      longDescription,
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Checkmark Animation and Confirmation
              isSignedUp
                  ? Column(
                      children: [
                        // Centering the checkmark animation
                        Center(
                          child: ScaleTransition(
                            scale: _animation,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 100, // Larger size
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'You are all signed up!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: signUpForEvent,
                        child: Text('Sign Me Up!'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
