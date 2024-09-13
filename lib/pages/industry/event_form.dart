import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class CreateEventForm extends StatefulWidget {
  @override
  _CreateEventFormState createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String? _eventName;
  String? _description;
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Controllers for the Date and Time Pickers
  TextEditingController _dateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Save the form
    _formKey.currentState!.save();

    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user signed in");
    }

    try {
      // Create a new event in the 'events' collection
      DocumentReference eventRef =
          await FirebaseFirestore.instance.collection('events').add({
        'event_name': _eventName,
        'description': _description,
        'date': _eventDate,
        'start_time': _startTime!.format(context),
        'end_time': _endTime!.format(context),
        'created_by': currentUser.uid,
      });

      // Update the current user's document with the new event ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'events': FieldValue.arrayUnion([eventRef.id]),
      });

      // Show a success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Event created successfully!')));

      // Clear the form or navigate back
      _formKey.currentState!.reset();
      _dateController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error creating event: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _eventDate = pickedDate;
        _dateController.text = DateFormat('yMMMd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context,
      TextEditingController controller, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Event Name
                TextFormField(
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the event name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _eventName = value;
                  },
                ),
                SizedBox(height: 16),

                // Description
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value;
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Event Date
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Event Date'),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Start Time
                TextFormField(
                  controller: _startTimeController,
                  decoration: InputDecoration(labelText: 'Start Time'),
                  readOnly: true,
                  onTap: () => _selectTime(context, _startTimeController, true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a start time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // End Time
                TextFormField(
                  controller: _endTimeController,
                  decoration: InputDecoration(labelText: 'End Time'),
                  readOnly: true,
                  onTap: () => _selectTime(context, _endTimeController, false),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an end time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _createEvent,
                  child: Text('Create Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
