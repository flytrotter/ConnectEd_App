import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';

class EditMeetingDetailsPage extends StatefulWidget {
  final String meetingId; // Scheduled meeting ID
  final String requestId; // Meeting request ID (if time needs to be fetched)
  final String userId;

  EditMeetingDetailsPage(
      {required this.meetingId, required this.requestId, required this.userId});

  @override
  _EditMeetingDetailsPageState createState() => _EditMeetingDetailsPageState();
}

class _EditMeetingDetailsPageState extends State<EditMeetingDetailsPage> {
  String? industryName;
  Map<String, dynamic>? meetingDetails;
  List<Map<String, dynamic>> availableSlots = [];
  Map<String, dynamic>? selectedSlot;
  TextEditingController emailController = TextEditingController();
  TextEditingController outlineController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String? selectedFile;
  bool isEmailValid = true;

  @override
  void initState() {
    super.initState();
    _fetchMeetingDetails();
    _fetchAvailableSlots();
  }

  Future<void> _fetchMeetingDetails() async {
    final meetingDoc = await FirebaseFirestore.instance
        .collection('scheduled_meetings')
        .doc(widget.meetingId)
        .get();

    if (meetingDoc.exists) {
      meetingDetails = meetingDoc.data();
      setState(() {
        industryName = meetingDetails!['industryName'];
        emailController.text = meetingDetails!['email'];
        outlineController.text = meetingDetails!['outline'];
        noteController.text = meetingDetails!['tutorNote'];
        selectedFile = meetingDetails!['resources'];
        selectedSlot = {
          'date': meetingDetails!['date'],
          'start_time': meetingDetails!['start_time'],
          'end_time': meetingDetails!['end_time']
        };
      });
    }
  }

  Future<void> _fetchAvailableSlots() async {
    final requestDoc = await FirebaseFirestore.instance
        .collection('meeting_requests')
        .doc(widget.requestId)
        .get();

    if (requestDoc.exists) {
      setState(() {
        availableSlots = List<Map<String, dynamic>>.from(requestDoc['times']);
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

  Future<void> _updateMeeting() async {
    if (isEmailValid && emailController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('scheduled_meetings')
          .doc(widget.meetingId)
          .update({
        'date': selectedSlot!['date'],
        'start_time': selectedSlot!['start_time'],
        'end_time': selectedSlot!['end_time'],
        'tutorNote': noteController.text,
        'email': emailController.text,
        'outline': outlineController.text,
        'resources': selectedFile,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meeting details updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
    }
  }

  Future<void> _cancelMeeting() async {
    await FirebaseFirestore.instance
        .collection('scheduled_meetings')
        .doc(widget.meetingId)
        .delete();

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Meeting cancelled.')),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      selectedFile = result.files.single.name;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Meeting Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (industryName != null)
                Text('Industry User: $industryName',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Available Slots:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: availableSlots.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selectedSlot == slot
                            ? Colors.purple.shade100
                            : null,
                        side: BorderSide(color: Colors.purple),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedSlot = slot;
                        });
                      },
                      child: Text(
                        _formatSlot(slot),
                        style: TextStyle(
                          color: Colors.purple.shade900,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                  errorText: isEmailValid
                      ? null
                      : 'Please enter a valid email address',
                ),
                onChanged: (value) {
                  setState(() {
                    isEmailValid = EmailValidator.validate(value);
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: outlineController,
                decoration: InputDecoration(
                  labelText: 'Outline of Presentation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(selectedFile != null
                    ? 'Selected: $selectedFile'
                    : 'Upload Resources'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Add a note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Center(child: Text('Update Meeting Details')),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _cancelMeeting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Center(child: Text('Cancel Meeting')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
