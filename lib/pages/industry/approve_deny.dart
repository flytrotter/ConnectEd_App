import 'package:app_test/components/uid_to_name.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart'; // For email validation
import 'package:file_picker/file_picker.dart'; // For file picking

class ApproveOrDenyPage extends StatefulWidget {
  final String requestId;
  final String teacherId;
  final String userId;

  ApproveOrDenyPage(
      {required this.requestId, required this.teacherId, required this.userId});

  @override
  _ApproveOrDenyPageState createState() => _ApproveOrDenyPageState();
}

class _ApproveOrDenyPageState extends State<ApproveOrDenyPage> {
  String? senderName;
  String? note;
  List<Map<String, dynamic>> availableSlots = [];
  Map<String, dynamic>? selectedSlot;
  TextEditingController tutorNoteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController outlineController = TextEditingController();
  String? currentName;
  String? selectedFile; // Store the file name
  bool isEmailValid = true; // For email validation

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
    _fetchTutorName();
  }

  Future<void> _fetchTutorName() async {
    currentName = await getFullName(widget.userId);
    setState(() {});
  }

  Future<void> _fetchRequestDetails() async {
    final requestDoc = await FirebaseFirestore.instance
        .collection('meeting_requests')
        .doc(widget.requestId)
        .get();

    if (requestDoc.exists) {
      final requestData = requestDoc.data()!;
      final senderId = requestData['senderId'];

      // Fetch the sender's full name
      final name = await getFullName(senderId);

      setState(() {
        senderName = name;
        note = requestData['note'];
        availableSlots = List<Map<String, dynamic>>.from(requestData['times']);
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

  Future<void> _approveMeeting() async {
    if (selectedSlot != null &&
        isEmailValid &&
        emailController.text.isNotEmpty) {
      // Add to scheduled_meetings collection
      await FirebaseFirestore.instance.collection('scheduled_meetings').add({
        'industryId': widget.userId,
        'industryName': currentName,
        'teacherId': widget.teacherId,
        'teacherName': senderName,
        'date': selectedSlot!['date'],
        'start_time': selectedSlot!['start_time'],
        'end_time': selectedSlot!['end_time'],
        'tutorNote': tutorNoteController.text,
        'email': emailController.text, // Store the email
        'outline': outlineController.text, // Store the outline
        'resources': selectedFile, // Store the selected file name
        'scheduledAt': Timestamp.now(),
        'requestId': widget.requestId,
      });

      await FirebaseFirestore.instance
          .collection('meeting_requests')
          .doc(widget.requestId)
          .delete();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Meeting Scheduled'),
          content: Text('The meeting has been scheduled successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please select a time slot and enter a valid email.')),
      );
    }
  }

  Future<void> _denyRequest() async {
    await FirebaseFirestore.instance
        .collection('meeting_requests')
        .doc(widget.requestId)
        .delete();

    Navigator.pop(context);
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
      appBar: AppBar(title: Text('Approve or Deny Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (senderName != null)
                Text('Sender: $senderName',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (note != null)
                Text('Note: $note', style: TextStyle(fontSize: 16)),
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
                controller: tutorNoteController,
                decoration: InputDecoration(
                  labelText: 'Add a note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _approveMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Center(child: Text('Approve and Schedule Meeting')),
              ),
              SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _denyRequest,
                  child: Text(
                    'Deny Request',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
