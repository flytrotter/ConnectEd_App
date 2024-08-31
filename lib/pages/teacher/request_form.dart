import 'package:app_test/components/get_current_id.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulingPage extends StatefulWidget {
  final String industryId;
  final String industryName;

  SchedulingPage({required this.industryId, required this.industryName});

  @override
  _SchedulingPageState createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  List<MeetingSlot> selectedSlots = [];
  TextEditingController noteController = TextEditingController();
  String? userId = getCurrentUserId();

  Future<void> _addNewSlot() async {
    if (selectedSlots.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 20 slots.')),
      );
      return;
    }

    // Pick a date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    // Pick start time
    TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedStartTime == null) return;

    // Pick end time
    TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime:
          pickedStartTime.replacing(minute: (pickedStartTime.minute + 30) % 60),
    );

    if (pickedEndTime == null) return;

    // Validate that end time is after start time
    final startDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedStartTime.hour,
      pickedStartTime.minute,
    );

    final endDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedEndTime.hour,
      pickedEndTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    // Create a new slot
    MeetingSlot newSlot = MeetingSlot(
      date: pickedDate,
      startTime: pickedStartTime,
      endTime: pickedEndTime,
    );

    // Confirm adding the slot
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Slot'),
        content: Text(
          'Add ${newSlot.formatted} to your meeting options?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Add'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        selectedSlots.add(newSlot);
      });
    }
  }

  void _sendRequest() {
    if (selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one time slot.')),
      );
      return;
    }

    FirebaseFirestore.instance.collection('meeting_requests').add({
      'senderId': userId, // Replace with the actual current user's ID
      'receiverId':
          widget.industryId, // The ID of the tutor receiving the request
      'times': selectedSlots.map((slot) => slot.toMap()).toList(),
      'note': noteController.text,
      'status': 'pending',
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request sent successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule a Meeting with ${widget.industryName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _addNewSlot,
              child: Text('Add New Slot'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: selectedSlots.isEmpty
                  ? Center(child: Text('No slots added yet.'))
                  : ListView.builder(
                      itemCount: selectedSlots.length,
                      itemBuilder: (context, index) {
                        final slot = selectedSlots[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            title: Text(slot.formatted),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  selectedSlots.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add a note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendRequest,
              child: Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingSlot {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  MeetingSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  String get formatted {
    final DateFormat dateFormat = DateFormat('EEEE, MMMM d');
    final String dateStr = dateFormat.format(date);
    String formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }

    return '$dateStr from ${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'start_time': '${startTime.hour}:${startTime.minute}',
      'end_time': '${endTime.hour}:${endTime.minute}',
    };
  }
}






















// import 'package:flutter/material.dart';

// class SchedulingPage extends StatefulWidget {
//   @override
//   _SchedulingPageState createState() => _SchedulingPageState();
// }

// class _SchedulingPageState extends State<SchedulingPage> {
//   List<DateTime?> selectedTimes = [];
//   TextEditingController noteController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Schedule a Meeting'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 DateTime? picked = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime.now(),
//                   lastDate: DateTime(2101),
//                 );
//                 if (picked != null && selectedTimes.length < 20) {
//                   setState(() {
//                     selectedTimes.add(picked);
//                   });
//                 }
//               },
//               child: Text('Select Time Slot'),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: selectedTimes.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(selectedTimes[index].toString()),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () {
//                       setState(() {
//                         selectedTimes.removeAt(index);
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//             TextField(
//               controller: noteController,
//               decoration: InputDecoration(hintText: 'Add a note'),
//             ),
//             Spacer(),
//             ElevatedButton(
//               onPressed: () {
//                 // Send request to tutor (to be implemented)
//               },
//               child: Text('Send Request'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// // import 'package:flutter/material.dart';
// // import 'package:table_calendar/table_calendar.dart';

// // class SchedulePage extends StatefulWidget {
// //   @override
// //   _SchedulePageState createState() => _SchedulePageState();
// // }

// // class _SchedulePageState extends State<SchedulePage> {
// //   final List<String> _selectedSlots = [];
// //   final TextEditingController _requestController = TextEditingController();

// //   // Dummy slot data for the example
// //   final List<String> _availableSlots = [
// //     '09:00 AM',
// //     '10:00 AM',
// //     '11:00 AM',
// //     '12:00 PM',
// //     '01:00 PM',
// //     '02:00 PM',
// //     '03:00 PM',
// //     '04:00 PM'
// //   ];

// //   void _toggleSlot(String slot) {
// //     setState(() {
// //       if (_selectedSlots.contains(slot)) {
// //         _selectedSlots.remove(slot);
// //       } else if (_selectedSlots.length < 20) {
// //         _selectedSlots.add(slot);
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Schedule Your Session'),
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             TableCalendar(
// //               focusedDay: DateTime.now(),
// //               firstDay: DateTime.utc(2020, 1, 1),
// //               lastDay: DateTime.utc(2023, 12, 31),
// //               onDaySelected: (selectedDay, focusedDay) {
// //                 // Handle date selection
// //               },
// //             ),
// //             SizedBox(height: 20),
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: _availableSlots.length,
// //                 itemBuilder: (context, index) {
// //                   final slot = _availableSlots[index];
// //                   final isSelected = _selectedSlots.contains(slot);
// //                   return ListTile(
// //                     title: Text(slot),
// //                     trailing: Icon(
// //                       isSelected
// //                           ? Icons.check_box
// //                           : Icons.check_box_outline_blank,
// //                       color: isSelected ? Colors.blue : null,
// //                     ),
// //                     onTap: () => _toggleSlot(slot),
// //                   );
// //                 },
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             TextField(
// //               controller: _requestController,
// //               decoration: InputDecoration(
// //                 labelText: 'Request Message',
// //                 border: OutlineInputBorder(),
// //               ),
// //               maxLines: 3,
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 // Handle form submission
// //                 print('Selected Slots: ${_selectedSlots.join(', ')}');
// //                 print('Request Message: ${_requestController.text}');
// //               },
// //               child: Text('Send Request'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
