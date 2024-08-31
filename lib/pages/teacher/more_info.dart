// import 'package:flutter/material.dart';

// class UserInfoPage extends StatelessWidget {
//   final Map<String, dynamic> userData;

//   UserInfoPage({required this.userData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${userData['first_name']} ${userData['last_name']}'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Name: ${userData['first_name']} ${userData['last_name']}'),
//             SizedBox(height: 8.0),
//             Text('Job Title: ${userData['job_title']}'),
//             SizedBox(height: 8.0),
//             Text('Company: ${userData['company_name']}'),
//             SizedBox(height: 8.0),
//             Text('Bio: ${userData['bio']}'), // Assuming there's a 'bio' field
//             // Add more fields as necessary
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:app_test/pages/teacher/request_form.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String userId;

  UserInfoPage({required this.userData, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '${userData['first_name']} ${userData['last_name']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '${userData['job_title']} at ${userData['company_name']}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 40, // Adjust height as needed
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildInterests(userData['interests'] ?? []),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Bio:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '${userData['experience']}',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SchedulingPage(
                                industryId: userId,
                                industryName:
                                    '${userData['first_name']} ${userData['last_name']}', // Pass the tutor's name]))
                              )));
                  // Navigator.pushReplacementNamed(context,
                  //     '/schedulePage'); // Add button functionality here
                },
                child: Text('Send a request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInterests(List<dynamic> interests) {
    return interests.map((interest) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Chip(
          label: Text(interest),
        ),
      );
    }).toList();
  }
}
