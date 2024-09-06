import 'package:app_test/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isTeacher = true; // Default to teacher
  int _currentStep = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Teacher-specific controllers
  final TextEditingController schoolNameController = TextEditingController();
  final List<String> subjects = [
    'Math 🧮',
    'Biology 🧬',
    'History 🏺',
    'English 📚',
    'Computer Science 💻',
    'Chemistry 🧪',
    'Business/Econ 💸',
    'Studio Art 🧑‍🎨',
    'Performing Arts 🎼',
    'Elementary Education 🏫',
    'Engineering ⚙️',
    'Social Justice ⚖️ ',
    'Human Health 🧑🏽‍⚕️'
  ];
  List<String> selectedSubjects = [];

  // Student-specific controllers
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  // final TextEditingController expertiseController = TextEditingController();
  final List<String> interests = [
    'Math 🧮',
    'Biology 🧬',
    'History 🏺',
    'English 📚',
    'Computer Science 💻',
    'Chemistry 🧪',
    'Business/Econ 💸',
    'Studio Art 🧑‍🎨',
    'Performing Arts 🎼',
    'Elementary Education 🏫',
    'Engineering ⚙️',
    'Social Justice ⚖️ ',
    'Human Health 🧑🏽‍⚕️'
  ];
  List<String> selectedInterests = [];

  String errorMessage = '';

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        Map<String, dynamic> userData = {
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'email': emailController.text,
          'role': isTeacher ? 'teacher' : 'student',
          'saved_users': [],
        };

        if (isTeacher) {
          userData.addAll({
            'school_name': schoolNameController.text,
            'subjects': selectedSubjects,
          });
        } else {
          userData.addAll({
            'company_name': companyNameController.text,
            'job_title': roleController.text,
            'linkedin': linkedInController.text,
            'experience': experienceController.text,
            // 'expertise': expertiseController.text,
            'interests': selectedInterests,
            'volunteer_hours': 0
          });
        }

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        // Get the FCM token and store it in Firestore
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? token = await messaging.getToken();
        if (token != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        }

        if (isTeacher) {
          Navigator.pushReplacementNamed(context, '/teacherPage');
        } else {
          Navigator.pushReplacementNamed(context, '/industryPage');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('Sign Up'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {}
        },
        onStepCancel:
            _currentStep == 0 ? null : () => setState(() => _currentStep -= 1),
        steps: [
          Step(
            title: Text('Account Type'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isTeacher = true;
                        });
                      },
                      icon: Icon(Icons.school),
                      label: Text('Teacher'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTeacher ? Colors.blue : Colors.grey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isTeacher = false;
                        });
                      },
                      icon: Icon(Icons.book),
                      label: Text('Student'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isTeacher ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: Text('Account Details'),
            isActive: _currentStep >= 1,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your first name' : null,
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your last name' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your email' : null,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your password' : null,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) => value != passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text(isTeacher ? 'Teacher Details' : 'Student Details'),
            isActive: _currentStep >= 2,
            content: isTeacher
                ? Column(
                    children: [
                      Text('Select Subjects You Teach'),
                      Wrap(
                        spacing: 10,
                        children: subjects.map((subject) {
                          return ChoiceChip(
                            label: Text(subject),
                            selected: selectedSubjects.contains(subject),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedSubjects.add(subject);
                                } else {
                                  selectedSubjects.remove(subject);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        controller: schoolNameController,
                        decoration: InputDecoration(labelText: 'School Name'),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your school name'
                            : null,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextFormField(
                        controller: companyNameController,
                        decoration:
                            InputDecoration(labelText: 'Current Company Name'),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your company name'
                            : null,
                      ),
                      TextFormField(
                        controller: roleController,
                        decoration:
                            InputDecoration(labelText: 'Role at Company'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your role' : null,
                      ),
                      TextFormField(
                        controller: linkedInController,
                        decoration: InputDecoration(
                            labelText: 'LinkedIn Account (Optional)'),
                      ),
                      TextFormField(
                        controller: experienceController,
                        decoration:
                            InputDecoration(labelText: 'Bio and Experience'),
                        maxLines: 5,
                        validator: (value) => value!.isEmpty
                            ? 'Please describe your experience'
                            : null,
                      ),
                      // TextFormField(
                      //   controller: expertiseController,
                      //   decoration:
                      //       InputDecoration(labelText: 'Area of Expertise'),
                      //   maxLines: 3,
                      //   validator: (value) => value!.isEmpty
                      //       ? 'Please enter your area of expertise'
                      //       : null,
                      // ),
                      const SizedBox(height: 25),
                      Text('Select Your Interests'),
                      Wrap(
                        spacing: 10,
                        children: interests.map((interest) {
                          return ChoiceChip(
                            label: Text(interest),
                            selected: selectedInterests.contains(interest),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedInterests.add(interest);
                                } else {
                                  selectedInterests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
          Step(
            title: Text('Submit'),
            isActive: _currentStep >= 3,
            content: ElevatedButton(
              onPressed: signUp,
              child: Text('Sign Up'),
            ),
          ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          // Hide the default controls on the last step
          return _currentStep == 3
              ? Container() // Hide the buttons
              : Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: details.onStepContinue,
                      child: const Text('CONTINUE'),
                    ),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('BACK'),
                      ),
                  ],
                );
        },
      ),
    );
  }
}
